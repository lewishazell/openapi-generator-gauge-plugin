package dev.hazell.openapi.gauge.codegen;

import org.openapitools.codegen.*;
import org.openapitools.codegen.languages.*;
import org.openapitools.codegen.model.*;
import io.swagger.models.properties.*;

import java.util.*;
import java.io.File;

public class PythonGaugeGenerator extends PythonClientCodegen {

    public PythonGaugeGenerator() {
        super();
        
        templateDir = "python-gauge";
    }

    @Override
    public String getName() {
        return "python-gauge";
    }

    @Override
    public String getHelp() {
        return "Custom Python generator with Gauge tests.";
    }

    @Override
    public void processOpts() {
        super.processOpts();

        final String defaultEnvFolder = "env" + File.separatorChar + "default";
        supportingFiles.add(new SupportingFile("test-requirements.mustache", "", "test-requirements.txt"));
        supportingFiles.add(new SupportingFile("gauge_steps.mustache", "step_impl", "step_impl.py"));
        supportingFiles.add(new SupportingFile("gauge_manifest.mustache", "", "manifest.json"));
        supportingFiles.add(new SupportingFile("gauge_default_properties.mustache", defaultEnvFolder, "default.properties"));
        supportingFiles.add(new SupportingFile("gauge_python_properties.mustache", defaultEnvFolder, "python.properties"));
    }
}