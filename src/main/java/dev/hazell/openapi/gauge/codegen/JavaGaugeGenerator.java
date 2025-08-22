package dev.hazell.openapi.gauge.codegen;

import org.openapitools.codegen.*;
import org.openapitools.codegen.languages.*;
import org.openapitools.codegen.model.*;
import io.swagger.models.properties.*;

import java.util.*;
import java.io.File;

public class JavaGaugeGenerator extends JavaClientCodegen {

    public JavaGaugeGenerator() {
        super();

        templateDir = "java-gauge";
    }

    @Override
    public String getName() {
        return "java-gauge";
    }

    @Override
    public String getHelp() {
        return "Custom Java generator with Gauge tests.";
    }

    @Override
    public void processOpts() {
        super.processOpts();
        
        final String defaultEnvFolder = "env" + File.separatorChar + "default";
        supportingFiles.add(new SupportingFile("pom.mustache", "", "pom.xml"));
        supportingFiles.add(new SupportingFile("build.gradle.mustache", "", "build.gradle"));
        supportingFiles.add(new SupportingFile("gauge_manifest.mustache", "", "manifest.json"));
        supportingFiles.add(new SupportingFile("gauge_steps.mustache", "src" + File.separatorChar + "test" + File.separatorChar + "java", "StepImplementation.java"));
        supportingFiles.add(new SupportingFile("gauge_default_properties.mustache", defaultEnvFolder, "default.properties"));
        supportingFiles.add(new SupportingFile("gauge_java_properties.mustache", defaultEnvFolder, "java.properties"));
    }
}