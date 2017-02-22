require "log4r"
require "vagrant"
require "vagrant-aci/action"

module VagrantPlugins
  module ACI
    class Provider < Vagrant.plugin("2", :provider)
      def initialize(machine)
        @machine = machine
      end

      def action(name)
       
      end

     
    end
  end
end
