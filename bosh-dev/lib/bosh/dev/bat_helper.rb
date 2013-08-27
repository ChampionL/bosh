require 'bosh/stemcell/infrastructure'
require 'bosh/dev/build'

module Bosh::Dev
  class BatHelper
    attr_reader :infrastructure

    def initialize(infrastructure, network_type = nil, build = Build.candidate)
      @infrastructure = Bosh::Stemcell::Infrastructure.for(infrastructure)
      @network_type = network_type
      @build = build
    end

    def bosh_stemcell_path
      build.bosh_stemcell_path(infrastructure, artifacts_dir)
    end

    def artifacts_dir
      File.join('/tmp', 'ci-artifacts', infrastructure.name, 'deployments')
    end

    def micro_bosh_deployment_dir
      File.join(artifacts_dir, micro_bosh_deployment_name)
    end

    def micro_bosh_deployment_name
      'microbosh'
    end

    def run_rake
      infrastructure_for_emitable_example

      sanitize_directories

      prepare_directories

      fetch_stemcells

      if (infrastructure.name == 'openstack' && network_type)
        Rake::Task["spec:system:#{infrastructure.name}:deploy_micro_#{network_type}_net"].invoke
      else
        Rake::Task["spec:system:#{infrastructure.name}:micro"].invoke
      end
    end

    private

    attr_reader :build, :network_type

    def infrastructure_for_emitable_example
      ENV['BAT_INFRASTRUCTURE'] = infrastructure.name
    end

    def sanitize_directories
      FileUtils.rm_rf(artifacts_dir)
    end

    def prepare_directories
      FileUtils.mkdir_p(micro_bosh_deployment_dir)
    end

    def fetch_stemcells
      build.download_stemcell(infrastructure: infrastructure, name: 'bosh-stemcell', light: infrastructure.light?, output_directory: artifacts_dir)
    end

  end
end

