github.dismiss_out_of_range_messages

swiftformat.binary_path = "Pods/SwiftFormat/CommandLineTool/swiftformat"
swiftformat.check_format(fail_on_error: true)

swiftlint.config_file = '.swiftlint.yml'
swiftlint.binary_path = 'Pods/SwiftLint/swiftlint'
swiftlint.lint_files inline_mode: true 

# https://qiita.com/lovee/items/811eae37928447f06b36
class CheckResult
    attr_accessor :warnings, :errors, :title, :message

    def initialize(title)
        @warnings = 0
        @errors = 0
        @title = "## " + title
        @message = markdown_message_template
    end

    def markdown_message_template
        template = "確認項目 | 結果\n"
        template << "|--- | --- |\n"
        return template
    end
end

result = CheckResult.new("PR チェック")

## PR は `master` ブランチへ出してはいけない
result.message << "to ブランチ確認 |"
is_to_master = github.branch_for_base == "master"
if is_to_master
    fail "`master`ブランチへのPRは禁止されています。"
    result.message << ":x:\n"
    result.errors += 1
else
    result.message << ":o:\n"
end

markdown(result.title)
markdown(result.message)

# xcode_summary.ignored_files = 'Pods/**'
# xcode_summary.inline_mode = true
# xcode_summary.report 'build/reports/errors.json'
