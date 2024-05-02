% Run unit tests
import matlab.unittest.TestRunner;
import matlab.unittest.TestSuite;
import matlab.unittest.plugins.TestReportPlugin;
import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.codecoverage.CoverageReport
import matlab.unittest.plugins.codecoverage.CoverageResult

suite = TestSuite.fromProject(currentProject);

runner = TestRunner.withTextOutput;
htmlFolder = 'tests/results';
plugin = TestReportPlugin.producingHTML(htmlFolder);
runner.addPlugin(plugin);

sourceCodeFolder = "tbx";
reportFolder = "tests/coverageReport";
reportFormat = CoverageReport(reportFolder);
format = CoverageResult;
plugin = CodeCoveragePlugin.forFolder(sourceCodeFolder,"Producing",[reportFormat,format], ...
    IncludingSubfolders = true);
runner.addPlugin(plugin)

result = runner.run(suite);%runInParallel

assert(all([result.Passed]))

coverageResults = format.Result;
summary = coverageSummary(coverageResults,"statement");
