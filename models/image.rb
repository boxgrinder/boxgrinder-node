class Image 
  ACTIONS = { :build => 'BUILD', :package => 'PACKAGE', :convert => 'CONVERT', :remove => 'REMOVE' }
  STATUSES = { :new => 'NEW', :building => 'BUILDING', :built => 'BUILT', :error => 'ERROR', :removed => 'REMOVED', :removing => 'REMOVING' }
  FORMATS = { :raw => 'RAW', :vmware => 'VMWARE', :ec2 => 'EC2' }

  def initialize(attributes = nil)
    super
    self.status = STATUSES[:new]
    self.created_at = self.updated_at = Time.now
  end

end
