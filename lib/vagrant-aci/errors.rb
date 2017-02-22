require "vagrant"

module VagrantPlugins
  module ACI
    module Errors
      class VagrantCloudcenterError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_aci.errors")
      end

    end
  end
end