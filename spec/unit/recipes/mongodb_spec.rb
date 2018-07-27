require 'spec_helper'

describe 'mongodb::mongodb' do
  context 'When all attributes are default, on Ubuntu 16.04' do
    let(:chef_run) do
      # for a complete list of available platforms and versions see:
      # https://github.com/customink/fauxhai/blob/master/PLATFORMS.md
      runner = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04')
      runner.converge(described_recipe)
    end
    it 'should update' do
      expect(chef_run).to update_apt_update 'update'
    end
    it 'should add mongo to the source list' do
      expect(chef_run).to add_apt_repository('mongodb')
    end
    it 'should install mongod and upgrade' do
      expect(chef_run).to upgrade_package 'mongodb-org'
    end
    it 'should enable service mongod' do
      expect(chef_run).to enable_service 'mongod'
    end
    it 'should start service mongod' do
      expect(chef_run).to start_service 'mongod'
    end
    it 'should update the mongo service config' do
      expect(chef_run).to create_template('/lib/systemd/system/mongod.service').with(source: 'mongod.service.erb')
      template = chef_run.template('/lib/systemd/system/mongod.service')
      expect(template).to notify('service[mongod]')
    end
    it 'should update the mongod config' do
      expect(chef_run).to create_template('/etc/mongod.conf').with_variables(port: 27017, ip_address: ['0.0.0.0'])
      template = chef_run.template('/etc/mongod.conf')
      expect(template).to notify('service[mongod]')
    end
      at_exit { ChefSpec::Coverage.report! }
  end
end
