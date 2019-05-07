require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class InstallProvisioningProfileHelper
      def self.show_message
        UI.message("Hello from the install_provisioning_profile plugin helper!")
      end

      def self.install_profile_from_path(path)
        Helper::InstallProvisioningProfileHelper.ensure_profiles_dir_created()
        Helper::InstallProvisioningProfileHelper.install_profile(path)
      end

      def self.install_profiles_from_list(profiles_list)
        filtered_profiles = profiles_list.select do |profile_path|
          profile_extension = File.extname(profile_path)
          profile_extension == PROFILE_EXTENSION
        end

        raise "There are no #{PROFILE_EXTENSION} files in list #{profiles_list}" if filtered_profiles.count == 0

        Helper::InstallProvisioningProfileHelper.ensure_profiles_dir_created()
        filtered_profiles.each { |profile_path|
          Helper::InstallProvisioningProfileHelper.install_profile(profile_path)
        }
      end

      def self.install_profiles_from_dir(profiles_dir)
        filtered_profiles = Dir.entries(profiles_dir).select do |profile_path|
          profile_extension = File.extname(profile_path)
          profile_extension == PROFILE_EXTENSION
        end

        raise "There are no #{PROFILE_EXTENSION} files in directory #{profiles_dir}" if filtered_profiles.count == 0

        Helper::InstallProvisioningProfileHelper.ensure_profiles_dir_created()
        filtered_profiles.each { |profile_path|

          Helper::InstallProvisioningProfileHelper.install_profile(File.join(profiles_dir, profile_path))
        }
      end

      private

      PROFILE_EXTENSION = '.mobileprovision'
      DEFAULT_PROFILES_PATH = '~/Library/MobileDevice/Provisioning Profiles'

      def self.ensure_profiles_dir_created()
        dest_profiles_dir = File.expand_path(DEFAULT_PROFILES_PATH)
        FileUtils.mkdir_p(dest_profiles_dir)
      end

      def self.install_profile(profile_path)
        profile_file_name = File.basename(profile_path)
        profile_extension = File.extname(profile_path)

        raise "Incorrect file name #{profile_path}" if profile_file_name.nil?
        raise "Incorrect file extension for #{profile_path}. Must be mobileprovision" if profile_extension != PROFILE_EXTENSION

        require 'tmpdir'
        Dir.mktmpdir('fastlane') do |dir|
          err = "#{dir}/grep.err"
          profile_uuid = `grep -aA1 UUID "#{profile_path}" | grep -io "[a-z0-9]\\{8\\}-[a-z0-9]\\{4\\}-[a-z0-9]\\{4\\}-[a-z0-9]\\{4\\}-[a-z0-9]\\{12\\}" 2> #{err}`

          raise RuntimeError, "UUID parsing failed #{profile_path}. Exit: #{$?.exitstatus}: #{File.read(err)}" if $?.exitstatus != 0

          profile_uuid = profile_uuid.strip
          raise RuntimeError, "UUID is empty for file #{profile_path}" if (profile_uuid.nil? || profile_uuid.empty?)

          dest_profiles_dir = File.expand_path(DEFAULT_PROFILES_PATH)
          dest_profile_path = File.join(dest_profiles_dir, "#{profile_uuid}#{PROFILE_EXTENSION}")

          UI.message("install_provisioning_profile: installing profile: #{profile_path} dest_profile_path: #{dest_profile_path} profile_uuid: #{profile_uuid}")

          FileUtils.install(profile_path, dest_profile_path)
        end
      end
    end
  end
end
