require "vagrant"

module VagrantPlugins
  module ACI
    class Config < Vagrant.plugin("2", :config)
      # The username for ACI
      #
      # @return [String]
      attr_accessor :username

      # The host ip of ACI
      #
      # @return [String]
      attr_accessor :ip

      # The tenant name for ACI
      #
      # @return [String]
      attr_accessor :tenant
     
     # The password for the ACI user
      #
      # @return [String]
      attr_accessor :password

      def initialize(region_specific=false)
        @username              = UNSET_VALUE
        @password              = UNSET_VALUE
        @ip              = UNSET_VALUE
        @tenant              = UNSET_VALUE
        
	  end
    end
  end
end
