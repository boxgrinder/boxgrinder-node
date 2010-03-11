class Task
  def initialize( artifact, action, description, data = {} )
    @created_at       = Time.now
    @artifact         = artifact
    @action           = action
    @description      = description
    @data             = data
  end

  attr_reader :artifact
  attr_reader :action
  attr_reader :description
  attr_reader :created_at
  attr_reader :data
end
