properties {
	$pwd = Split-Path $psake.build_script_file	
	$build_directory  = "$pwd\output\condep-loadbalancer-ace"
	$configuration = "Release"
	$preString = "-beta"
	$releaseNotes = ""
	$nunitPath = "$pwd\..\src\packages\NUnit.Runners.2.6.3\tools"
	$nuget = "$pwd\..\tools\nuget.exe"
}
 
include .\..\tools\psake_ext.ps1

function GetNugetAssemblyVersion($assemblyPath) {
	$versionInfo = Get-Item $assemblyPath | % versioninfo

	return "$($versionInfo.FileMajorPart).$($versionInfo.FileMinorPart).$($versionInfo.FileBuildPart)$preString"
}

task default -depends Build-All, Pack-All
task ci -depends Build-All, Pack-All

task Build-All -depends Clean, ResotreNugetPackages, Build, Create-BuildSpec-ConDep-LoadBalancer-Ace
task Pack-All -depends Pack-ConDep-LoadBalancer-Ace

task ResotreNugetPackages {
	Exec { & $nuget restore "$pwd\..\src\condep-loadbalancer-ace.sln" }
}

task Build {
	Exec { msbuild "$pwd\..\src\condep-loadbalancer-ace.sln" /t:Build /p:Configuration=$configuration /p:OutDir=$build_directory /p:GenerateProjectSpecificOutputFolder=true}
}

task Clean {
	Write-Host "Cleaning Build output"  -ForegroundColor Green
	Remove-Item $build_directory -Force -Recurse -ErrorAction SilentlyContinue
}

task Create-BuildSpec-ConDep-LoadBalancer-Ace {
	Generate-Nuspec-File `
		-file "$build_directory\condep-loadbalancer-ace.nuspec" `
		-version $(GetNugetAssemblyVersion $build_directory\ConDep.Dsl.LoadBalancer.Ace\ConDep.Dsl.LoadBalancer.Ace.dll) `
		-id "ConDep.Dsl.LoadBalancer.Ace" `
		-title "ConDep.Dsl.LoadBalancer.Ace" `
		-licenseUrl "http://www.con-dep.net/license/" `
		-projectUrl "http://www.con-dep.net/" `
		-description "ConDep integration with the Cisco ACE Load Balancer. ConDep is a highly extendable Domain Specific Language for Continuous Deployment, Continuous Delivery and Infrastructure as Code on Windows." `
		-iconUrl "https://raw.github.com/condep/ConDep/master/images/ConDepNugetLogo.png" `
		-releaseNotes "$releaseNotes" `
		-tags "Continuous Deployment Delivery Infrastructure WebDeploy Deploy msdeploy IIS automation powershell remote aws azure load balancing cisco ace" `
		-dependencies @(
			@{ Name="ConDep.Dsl"; Version="[3.1.0$preString,4)"}
		) `
		-files @(
			@{ Path="ConDep.Dsl.LoadBalancer.Ace\ConDep.Dsl.LoadBalancer.Ace.dll"; Target="lib/net40"} 
		)
}

task Pack-ConDep-LoadBalancer-Ace {
	Exec { & $nuget pack "$build_directory\condep-loadbalancer-ace.nuspec" -OutputDirectory "$build_directory" }
}