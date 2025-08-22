package dev.hazell.openapi.gauge.codegen;

import org.openapitools.codegen.*;
import org.openapitools.codegen.languages.*;
import org.openapitools.codegen.model.*;
import io.swagger.models.properties.*;

import java.util.*;
import java.io.File;

public class GoGaugeGenerator extends GoClientCodegen {

    public GoGaugeGenerator() {
        super();
        
        templateDir = "go-gauge";
    }

    @Override
    public String getName() {
        return "go-gauge";
    }

    @Override
    public String getHelp() {
        return "Custom go generator with Gauge tests.";
    }

    @Override
    public void processOpts() {
        super.processOpts();

        final String defaultEnvFolder = "env" + File.separatorChar + "default";
        supportingFiles.add(new SupportingFile("gauge_steps.mustache", "test", "steps.go"));
        supportingFiles.add(new SupportingFile("gauge_manifest.mustache", "", "manifest.json"));
        supportingFiles.add(new SupportingFile("gauge_default_properties.mustache", defaultEnvFolder, "default.properties"));
        supportingFiles.add(new SupportingFile("gauge_go_properties.mustache", defaultEnvFolder, "go.properties"));
    }
}