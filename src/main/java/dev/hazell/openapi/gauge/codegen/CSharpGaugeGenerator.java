package dev.hazell.openapi.gauge.codegen;

import org.openapitools.codegen.*;
import org.openapitools.codegen.languages.*;
import org.openapitools.codegen.model.*;
import io.swagger.models.properties.*;

import java.util.*;
import java.io.File;

public class CSharpGaugeGenerator extends CSharpClientCodegen {

    public CSharpGaugeGenerator() {
        super();

        templateDir = "csharp-gauge";
    }

    @Override
    public String getName() {
        return "csharp-gauge";
    }

    @Override
    public String getHelp() {
        return "Custom C# generator with Gauge tests.";
    }

    @Override
    public void processOpts() {
        super.processOpts();
        
        final String testPackageName = testPackageName();
        final String testPackageFolder = testFolder + File.separator + testPackageName;
        final String defaultEnvFolder = testPackageFolder + File.separatorChar + "env" + File.separatorChar + "default";
        supportingFiles.add(new SupportingFile("netcore_testproject.mustache", testPackageFolder, testPackageName + ".csproj"));
        supportingFiles.add(new SupportingFile("gauge_steps.mustache", testPackageFolder, "StepImplementation.cs"));
        supportingFiles.add(new SupportingFile("gauge_manifest.mustache", testPackageFolder, "manifest.json"));
        supportingFiles.add(new SupportingFile("gauge_default_properties.mustache", defaultEnvFolder, "default.properties"));
        supportingFiles.add(new SupportingFile("gauge_dotnet_properties.mustache", defaultEnvFolder, "dotnet.properties"));
    }
}