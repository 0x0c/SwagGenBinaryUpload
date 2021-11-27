import "./const.rb"

platform :ios do
  private_lane :export_app do |options|
    configuration = "Debug"
    if options[:configuration]
      configuration = options[:configuration]
    end

    export_method = "development"
    profiles = {
      BUNDLE_IDENTIFIER => "#{BUNDLE_IDENTIFIER} Development",
    }

    if options[:export_method]
      export_method = options[:export_method]
      if export_method == "app-store"
        development = false
        profiles = {
          BUNDLE_IDENTIFIER => "#{BUNDLE_IDENTIFIER} AppStore",
        }
      end
    end

    export_team_id = ENV["TEAM_ID"]
    if options[:export_team_id]
      export_team_id = options[:export_team_id]
    end

    prepare()

    gym(
      workspace: "#{PROJECT_NAME}.xcworkspace",
      configuration: configuration,
      scheme: "Your App",
      clean: true,
      silent: false,
      export_method: export_method,
      export_team_id: export_team_id,
      export_options: {
        provisioningProfiles: profiles,
      },
      output_directory: "build/",
      buildlog_path: "build/"
    )
  end

  private_lane :commit_project_yml do
    git_commit(
      path: [
        "project.yml"
      ],
      message: "Version Bump"
    )
  end

  private_lane :upload_to_firebase do |options|
    app_id = FIREBASE_APP_ID
    additional_notes = ""
    if options[:additional_notes]
      additional_notes = options[:additional_notes]
      additional_notes += "\n\n"
    end
    if options[:app_id]
      app_id = options[:app_id]
    end

    changelog = changelog_from_git_commits({
      merge_commit_filtering: "exclude_merges",
    })

    firebase_app_distribution(
      app: FIREBASE_APP_ID,
      release_notes: "#{additional_notes}#{changelog}",
      firebase_cli_token: FIREBASE_CI_TOKEN,
      groups: FIREBASE_APP_DISTRIBUTION_GROUP,
      debug: true
    )
    upload_symbols_to_crashlytics(
      dsym_path: "./build/#{PROJECT_NAME}.app.dSYM.zip"
    )
  end

  desc "変更したアイコンや.xcodeprojなどのファイルを変更前の状態に戻す"
  private_lane :restore_resources do
    sh "git checkout ../#{PROJECT_NAME}/Assets.xcassets/AppIcon.appiconset/"
  end

  desc "Development用のProvisioning profileで署名できるか確認する"
  private_lane :check_development_signing do |options|
    fetch_development_provisioning_profile
    export_app(skip_xcodegen: options[:skip_xcodegen])
  end

  desc "Distribution用のProvisioning profileで署名できるか確認する"
  private_lane :check_distribution_signing do |options|
    fetch_distribution_provisioning_profile
    export_app(configuration: "Release", export_method: "app-store", skip_xcodegen: options[:skip_xcodegen])
  end
end
