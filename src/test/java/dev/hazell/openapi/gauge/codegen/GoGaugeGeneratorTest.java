package dev.hazell.openapi.gauge.codegen;

import org.junit.jupiter.api.Test;
import org.openapitools.codegen.ClientOptInput;
import org.openapitools.codegen.DefaultGenerator;
import org.openapitools.codegen.config.CodegenConfigurator;

public class GoGaugeGeneratorTest {

  public static void main(String[] args) {
    GoGaugeGeneratorTest test = new GoGaugeGeneratorTest();
    test.launchCodeGenerator();
  }

  @Test
  public void launchCodeGenerator() {
    final CodegenConfigurator configurator = new CodegenConfigurator()
              .setGeneratorName("go-gauge")
              .setInputSpec("tests/petstore-extended.yaml")
              .setOutputDir("out/go-gauge"); // output directory

    final ClientOptInput clientOptInput = configurator.toClientOptInput();
    DefaultGenerator generator = new DefaultGenerator();
    generator.opts(clientOptInput).generate();
  }
}