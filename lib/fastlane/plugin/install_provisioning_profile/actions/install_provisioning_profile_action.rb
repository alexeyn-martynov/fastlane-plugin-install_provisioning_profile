require 'fastlane/action'
require_relative '../helper/install_provisioning_profile_helper'

module Fastlane
  module Actions
    class InstallProvisioningProfileAction < Action
      def self.run(params)
        UI.message("install_provisioning_profile plugin. file: #{params[:file]} directory: #{params[:directory]} files: #{params[:files]}")

        if params[:file]
          Helper::InstallProvisioningProfileHelper.install_profile_from_path(params[:file])
        elsif params[:files]
          Helper::InstallProvisioningProfileHelper.install_profiles_from_list(params[:files])
        elsif params[:directory]
          Helper::InstallProvisioningProfileHelper.install_profiles_from_dir(params[:directory])
        end        
      end

      def self.description
        "This plugin installs provisioning profile to Xcode Provisioning Profiles directory"
      end

      def self.authors
        ["Alexey Martynov"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Xcode stores all provisioning profiles in ~/Library/MobileDevice/Provisioning Profiles directory. This plugin allow you to copy provisioning profile to this internal directory."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :file,
                                  env_name: "INSTALL_PROVISIONING_PROFILE_FILE",
                               description: "Path to .mobileprovisioning file to install",
                       conflicting_options: [:directory, :files],
                                  optional: true,
                                      type: String,
                              verify_block: proc do |value|
                                 UI.user_error!("No file given, pass using `file: 'PATH_TO_MOBILEPROVISIONING_FILE'`") unless value and !value.empty?
                               end),
          FastlaneCore::ConfigItem.new(key: :directory,
                                  env_name: "INSTALL_PROVISIONING_PROFILE_DIRECTORY",
                               description: "Path to directory containing .mobileprovisioning files to install",
                       conflicting_options: [:file, :files],
                                  optional: true,
                                      type: String,
                              verify_block: proc do |value|
                                 UI.user_error!("No directory given, pass using `directory: 'PATH_TO_DIR_WITH_MOBILEPROVISIONING_FILES'`") unless value and !value.empty?
                               end),
          FastlaneCore::ConfigItem.new(key: :files,
                                  env_name: "INSTALL_PROVISIONING_PROFILE_FILES",
                               description: "List of .mobileprovisioning file paths to install",
                       conflicting_options: [:directory, :file],
                                  optional: true,
                                      type: Array,
                              verify_block: proc do |value|
                                 UI.user_error!("No files given, pass using `file: 'PATH_TO_MOBILEPROVISIONING_FILES'`") unless value and !value.empty?
                               end),
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end
