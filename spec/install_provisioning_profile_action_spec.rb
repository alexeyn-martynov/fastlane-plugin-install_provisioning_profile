describe Fastlane::Actions::InstallProvisioningProfileAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The install_provisioning_profile plugin is working!")

      Fastlane::Actions::InstallProvisioningProfileAction.run(nil)
    end
  end
end
