defmodule UAInspector.ClientHintsTest do
  use ExUnit.Case, async: true

  alias UAInspector.ClientHints

  test "header parsing" do
    expected = %ClientHints{
      application: "com.ua_inspector.test",
      architecture: "x86",
      bitness: "64",
      form_factors: ["desktop", "mobile"],
      full_version: "98.0.14335.105",
      full_version_list: [
        {" Not A;Brand", "99.0.0.0"},
        {"Chromium", "98.0.4758.82"},
        {"Opera", "98.0.4758.82"}
      ],
      mobile: true,
      model: "DN2103",
      platform: "Ubuntu",
      platform_version: "3.7"
    }

    parsed =
      ClientHints.new([
        {"i-am", "test"},
        {"sec-ch-ua", ~s(" Not A;Brand";v="99", "Chromium";v="98", "Opera";v="84")},
        {"sec-ch-ua-arch", "x86"},
        {"sec-ch-ua-bitness", "64"},
        {"sec-ch-ua-form-factors", ~s("Desktop", "Mobile")},
        {"sec-ch-ua-full-version", "98.0.14335.105"},
        {"sec-ch-ua-full-version-list",
         ~s(" Not A;Brand";v="99.0.0.0", "Chromium";v="98.0.4758.82", "Opera";v="98.0.4758.82")},
        {"sec-ch-ua-mobile", "?1"},
        {"sec-ch-ua-model", "DN2103"},
        {"sec-ch-ua-platform", "Ubuntu"},
        {"sec-ch-ua-platform-version", "3.7"},
        {"x-requested-with", "com.ua_inspector.test"}
      ])

    assert ^expected = parsed
  end

  test "sec-ch-ua-full-list-version takes precedence over sec-ch-ua" do
    expected = %ClientHints{
      full_version_list: [
        {" Not A;Brand", "99.0.0.0"},
        {"Chromium", "98.0.4758.82"},
        {"Opera", "98.0.4758.82"}
      ]
    }

    parsed =
      ClientHints.new([
        {"sec-ch-ua", ~s("Parsed And Ignored";v="99")},
        {"sec-ch-ua-full-version-list",
         ~s(" Not A;Brand";v="99.0.0.0", "Chromium";v="98.0.4758.82", "Opera";v="98.0.4758.82")},
        {"sec-ch-ua", ~s("Skipped";v="99")}
      ])

    assert ^expected = parsed
  end

  test "noop for empty headers" do
    assert %ClientHints{} = ClientHints.new([])
  end
end
