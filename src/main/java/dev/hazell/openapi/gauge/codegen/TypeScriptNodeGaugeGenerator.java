package dev.hazell.openapi.gauge.codegen;

import org.openapitools.codegen.*;
import org.openapitools.codegen.languages.*;
import org.openapitools.codegen.model.*;
import io.swagger.models.properties.*;

import java.util.*;
import java.io.File;

public class TypeScriptNodeGaugeGenerator extends TypeScriptNodeClientCodegen {

    public TypeScriptNodeGaugeGenerator() {
        super();
        
        templateDir = "typescript-node-gauge";
    }

    @Override
    public String getName() {
        return "typescript-node-gauge";
    }

    @Override
    public String getHelp() {
        return "Custom TypeScriptNode generator with Gauge tests.";
    }

    @Override
    public void processOpts() {
        super.processOpts();

        final String defaultEnvFolder = "env" + File.separatorChar + "default";
        supportingFiles.add(new SupportingFile("tsconfig.mustache", "", "tsconfig.json"));
        supportingFiles.add(new SupportingFile("package.mustache", "", "package.json"));
        supportingFiles.add(new SupportingFile("gauge_steps.mustache", "tests", "StepImplementation.ts"));
        supportingFiles.add(new SupportingFile("gauge_manifest.mustache", "", "manifest.json"));
        supportingFiles.add(new SupportingFile("gauge_default_properties.mustache", defaultEnvFolder, "default.properties"));
        supportingFiles.add(new SupportingFile("gauge_ts_properties.mustache", defaultEnvFolder, "ts.properties"));
    }
}