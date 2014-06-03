class Phrender::Drivers
  class << self
    def emberjs
      File.read File.join(File.dirname(__FILE__), 'drivers', 'ember.js')
    end
  end
end

