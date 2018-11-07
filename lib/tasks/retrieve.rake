desc "Retrieve users data from Google Fit and pass to Memair"
task :retrieve => :environment do
  user       = User.where(retrieved_until: nil)&.first || User.order(:retrieved_until).first

  start_date = user.retrieved_until || Time.now.utc.to_date - 90.day
  end_date   = [Time.now.utc.to_date - 1.day, start_date + 10.days].min

  puts "user: #{user.email}"
  puts "retrieved_until: #{user.retrieved_until || 'NEVER RUN'}"
  puts "start_date: #{start_date}"
  puts "end_date: #{end_date}"

  if start_date < end_date
    user.refresh_google_token! unless user.valid_google_token?
    user.set_data_sources if user.google_data_sources.nil?

    biometrics = ''
    physical_activities = ''

    fitness = Google::Apis::FitnessV1::FitnessService.new
    fitness.authorization = user.google_access_token

    start_time_millis = start_date.to_datetime.to_i * 1000
    end_time_millis = end_date.to_datetime.to_i * 1000

    bucket_by_time = Google::Apis::FitnessV1::BucketByTime.new
    bucket_by_time.duration_millis = 60 * 1000

    aggregatables = []

    data_stream_ids = user.data_stream_ids

    if data_stream_ids.include?('derived:com.google.step_count.delta:com.google.android.gms:estimated_steps')
      aggregate_by_steps = Google::Apis::FitnessV1::AggregateBy.new
      aggregate_by_steps.data_type_name = 'com.google.step_count.delta'
      aggregate_by_steps.data_source_id = 'derived:com.google.step_count.delta:com.google.android.gms:estimated_steps'
      aggregatables.append(aggregate_by_steps)
    end

    if data_stream_ids.include?('derived:com.google.heart_rate.bpm:com.google.android.gms:merge_heart_rate_bpm')
      aggregate_by_bpm = Google::Apis::FitnessV1::AggregateBy.new
      aggregate_by_bpm.data_type_name = 'com.google.heart_rate.bpm'
      aggregate_by_bpm.data_source_id = 'derived:com.google.heart_rate.bpm:com.google.android.gms:merge_heart_rate_bpm'
      aggregatables.append(aggregate_by_bpm)
    end

    if data_stream_ids.include?('derived:com.google.weight:com.google.android.gms:merge_weight')
      aggregate_by_weight = Google::Apis::FitnessV1::AggregateBy.new
      aggregate_by_weight.data_type_name = 'com.google.weight'
      aggregate_by_weight.data_source_id = 'derived:com.google.weight:com.google.android.gms:merge_weight'
      aggregatables.append(aggregate_by_weight)
    end

    unless aggregatables.empty?

      aggregate_request = Google::Apis::FitnessV1::AggregateRequest.new
      aggregate_request.aggregate_by = aggregatables
      aggregate_request.bucket_by_time = bucket_by_time
      aggregate_request.start_time_millis = start_time_millis
      aggregate_request.end_time_millis = end_time_millis

      raw_fitness_data_by_minute = fitness.aggregate_dataset('me', aggregate_request)

      raw_fitness_data_by_minute.bucket.each do |bucket|
        date = Time.at(bucket.start_time_millis/1000).utc
        bucket.dataset.each do |dataset|
          if dataset.data_source_id.include?('com.google.heart_rate')
            bpm = dataset.point&.first&.value&.first&.fp_val
            source = dataset.point&.first&.origin_data_source_id
            biometrics += "{timestamp: \"#{date}\" value: #{bpm} type: heart_rate source: \"#{source}\"}" unless bpm.nil?
          end

          if dataset.data_source_id.include?('com.google.step_count')
            steps = dataset.point&.first&.value&.first&.int_val
            source = dataset.point&.first&.origin_data_source_id
            physical_activities += "{timestamp: \"#{date}\" notes: \"#{steps} steps\" type: #{steps > 100 ? 'running' : 'walking'} source: \"#{source}\"}" unless steps.nil?
          end

          if dataset.data_source_id.include?('com.google.weight')
            weight = dataset.point&.first&.value&.first&.fp_val
            source = dataset.point&.first&.origin_data_source_id
            biometrics += "{timestamp: \"#{date}\" value: #{weight} type: weight source: \"#{source}\"}" unless weight.nil?
          end
        end
      end

      unless biometrics.empty? && physical_activities.empty?
        memair = Memair.new(user.memair_access_token)

        query = """
          mutation {
            BulkCreate(
              biometrics: [#{biometrics}]
              physical_activities: [#{physical_activities}]
            ) {
              id
              records_total
            }
          }
        """
        response = memair.query(query)
        puts response.to_s
      end
    end

    user.retrieved_until = end_date
    user.save
  end
end
