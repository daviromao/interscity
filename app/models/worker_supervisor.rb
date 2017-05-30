require 'singleton'

class WorkerSupervisor
  include Singleton

  @@resource_id_status = $redis

  INACTIVE ||= 0
  ACTIVE ||= 1
  UPDATED ||= 2

  def start_resource_creation(workers = 1)
    workers.times do
      CreateResources.perform_async
    end
  end

  def start_resource_update(workers = 1)
    workers.times do
      UpdateResources.perform_async
    end
  end
end
