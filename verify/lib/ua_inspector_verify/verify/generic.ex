defmodule UAInspectorVerify.Verify.Generic do
  @moduledoc """
  Verify a generic fixture against a result.
  """

  @smarttva_brand_detect [
    "Mozilla/5.0 (Linux ) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36 OPR/46.0.2207.0 OMI/4.13.5.431.SIERRA.150 Model/Vestel-MB230 VSTVB MB200 FVC/4.0 (SOLAS; MB230; ) SmartTvA/3.0.0",
    "Mozilla/5.0 (Linux ) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.120 Safari/537.36 OPR/46.0.2207.0 OMI/4.20.5.61.LIMA.179 Model/Vestel-MB181 VSTVB MB100 FVC/5.0 (ALTIMO; MB181; ) SmartTvA/3.0.0",
    "Mozilla/5.0 (X11;Linux armv7l) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.4280.88 Safari/537.36 Model/NT6904K (SKW690;WHALEOSSKWNT6904KTVP1;WHALEOS-SKW-NT6904KTV-1000051.000;;_TV_NT6904K_HHbrowser_2k22;) LaTivu_1.0.1_2022 CE-HTML/1.0 NETTV_4.6.0.1 SignOn/2.0 SmartTvA/5.0.0 WhaleTV/3.0 WhaleBrowser/1.1.933.1 en",
    "Mozilla/5.0 (X11;Linux armv7l) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4280.88 Safari/537.36 Model/NT726902K (Cultraview690;WHALEOSJRXNT6902KTVP66;WHALEOS-DK-NT6902KTV-0000040.000;;_TV_NT726902K_HHbrowser_2k22;) LaTivu_1.0.1_2022 CE-HTML/1.0 NETTV_4.6.0.1 SignOn/2.0 SmartTvA/5.0.0 WhaleTV/3.0 WhaleBrowser/1.3.21.5 en",
    "Mozilla/5.0 (X11;Linux armv7l) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4280.88 Safari/537.36 Model/NT726902K (Toptech690;WHALEOSDKNT6902KTVP41;WHALEOS-DK-NT6902KTV-0000082.000;;_TV_NT726902K_HHbrowser_2k22;) LaTivu_1.0.1_2022 CE-HTML/1.0 NETTV_4.6.0.1 SignOn/2.0 SmartTvA/5.0.0 WhaleTV/3.0 WhaleBrowser/1.3.240509.0 en",
    "Opera/9.80 (Linux mips; ) Presto/2.12.407 Version/12.51 MB97/0.39.24.3 (FITCO, Mxl661L32, wireless) VSTVB_MB97 UID(00:09:DF:F9:EE:D8/MB97/FITCO/0.39.24.3)+CE-HTML;MEM:HIGH SmartTvA/3.0.0",
    "Opera/9.80 (Linux mips; ) Presto/2.12.407 Version/12.51 MB97/0.39.24.3 (NEO, Mxl661L32, wired) VSTVB_MB97  SmartTvA/3.0.0"
  ]

  @smarttva_model_detect [
    "Mozilla/5.0 (Linux armv7l) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36 OPR/36.0.2128.0 OMI/4.8.0.129.Driver3.34 , AOC_TV/018.002.169.001 (AOC, U60856, wireless)  CE-HTML/1.0 NETTV/4.6.0.1 SignOn/2.0 SmartTvA/5.0.0 en",
    "Mozilla/5.0 (Linux armv7l) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36 OPR/36.0.2128.0 OMI/4.8.0.53.Driver.72 , AOC_TV/012.002.072.001 (AOC, LE55U7970-30, wireless) CE-HTML/1.0 NETTV/4.5.0 SignOn/2.0 SmartTvA/4.0.0 en",
    "Mozilla/5.0 (Linux armv7l) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36 OPR/36.0.2128.0 OMI/4.8.0.66.Driver2.33 , AOC_TV/012.002.049.001 (AOC, LE32S5970-30, wireless) CE-HTML/1.0 NETTV/4.5.0 SignOn/2.0 SmartTvA/4.0.0 en",
    "Mozilla/5.0 (Linux armv7l) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36 OPR/36.0.2128.0 OMI/4.8.0.66.Driver2.33 , AOC_TV/012.002.058.001 (AOC, LE32S5970-20, wireless) CE-HTML/1.0 NETTV/4.5.0 SignOn/2.0 SmartTvA/4.0.0 en",
    "Mozilla/5.0 (Linux armv7l) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36 OPR/36.0.2128.0 OMI/4.8.0.66.Driver2.33 , AOC_TV/012.002.067.001 (AOC, LE32S5970s-20, wireless) CE-HTML/1.0 NETTV/4.5.0 SignOn/2.0 SmartTvA/4.0.0 en",
    "Mozilla/5.0 (Linux armv7l) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36 OPR/36.0.2128.0 OMI/4.8.0.66.Driver2.33 , AOC_TV/012.002.067.001 (AOC, LE43S5970s-20, wired) CE-HTML/1.0 NETTV/4.5.0 SignOn/2.0 SmartTvA/4.0.0 en",
    "Mozilla/5.0 (Linux armv7l) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36 OPR/36.0.2128.0 OMI/4.8.0.66.Driver2.33 , AOC_TV/012.002.067.001 (AOC, LE43S5970s-28, wireless) CE-HTML/1.0 NETTV/4.5.0 SignOn/2.0 SmartTvA/4.0.0 en",
    "Mozilla/5.0 (Linux armv7l) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36 OPR/36.0.2128.0 OMI/4.8.0.66.Driver2.33 , AOC_TV/012.002.067.001 (AOC, LE43S5977-20, wireless) CE-HTML/1.0 NETTV/4.5.0 SignOn/2.0 SmartTvA/4.0.0 en",
    "Mozilla/5.0 (Linux armv7l) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.120 Safari/537.36 OPR/46.0.2207.0 OMI/4.20.4.54.Nebula.11 Model/Tango-NT72671(AOC;50U6305/43I;205.002.153.001;_TV_NT72671_Cosmos_2k20) SignOn/2.0 WhaleTV/2.0 NETTV/4.6.0.1 SmartTvA/5.0.0 es"
  ]

  @smarttva_brand_update [
    "Mozilla/5.0 (Linux ) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.5359.128 Safari/537.36 OPR/46.0.2207.0 OMI/4.23.2.96.LIMA2.91 Model/Vestel-MB181 VSTVB MB100 TiVoOS/1.0.0 (Vestel MB181 FINLUX) SmartTvA/3.0.0",
    "Mozilla/5.0 (Linux; Andr0id 8.0; TPM171E Build/OC) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36 OPR/32.0.2128.0 OMI/4.8.0.129.Sprinter6.112(;Philips;49PUS7002/62;TPM171E_R.107.001.143.000;_TV_5596;) CE-HTML/1.0 NETTV/8.0.2 SmartTvA/5.0.0"
  ]

  @smarttva_model_update [
    "Mozilla/5.0 (Linux; Andr0id 11.0; TPM191E Build/RTT2.211108.001) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36 OPR/32.0.2128.0 OMI/4.8.0.129.Typhoon2.10(;Philips;50PUS7304/62;TPM191E_R.201.000.248.227;_TV_5599;) CE-HTML/1.0 NETTV/9.0.0 SmartTvA/5.0.0 WH/1.0",
    "Mozilla/5.0 (Linux; Andr0id 11.0; TPM191E Build/RTT2.211108.001) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36 OPR/32.0.2128.0 OMI/4.8.0.129.Typhoon2.10(;Philips;50PUS8505/62;TPM191E_R.201.000.248.227;_TV_5599;) CE-HTML/1.0 NETTV/9.0.0 SmartTvA/5.0.0 WH/1.0",
    "Mozilla/5.0 (Linux; Andr0id 8.0; TPM171E Build/OC) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36 OPR/32.0.2128.0 OMI/4.8.0.129.Sprinter6.112(;Philips;49PUS7002/62;TPM171E_R.107.001.143.000;_TV_5596;) CE-HTML/1.0 NETTV/8.0.2 SmartTvA/5.0.0"
  ]

  def verify(
        %{user_agent: user_agent, device: %{brand: device_brand}} = testcase,
        %{device: %{brand: :unknown} = result_device} = result
      )
      when user_agent in @smarttva_brand_detect do
    # improved detection in upcoming remote release
    verify(
      testcase,
      %{result | device: %{result_device | brand: device_brand}}
    )
  end

  def verify(
        %{user_agent: user_agent, device: %{model: device_model}} = testcase,
        %{device: %{model: :unknown} = result_device} = result
      )
      when user_agent in @smarttva_model_detect do
    # improved detection in upcoming remote release
    verify(
      testcase,
      %{result | device: %{result_device | model: device_model}}
    )
  end

  def verify(
        %{user_agent: user_agent, device: %{brand: device_brand}} = testcase,
        %{device: %{brand: result_brand} = result_device} = result
      )
      when user_agent in @smarttva_brand_update and device_brand != result_brand do
    # improved detection in upcoming remote release
    verify(
      testcase,
      %{result | device: %{result_device | brand: device_brand}}
    )
  end

  def verify(
        %{user_agent: user_agent, device: %{model: device_model}} = testcase,
        %{device: %{model: result_model} = result_device} = result
      )
      when user_agent in @smarttva_model_update and device_model != result_model do
    # improved detection in upcoming remote release
    verify(
      testcase,
      %{result | device: %{result_device | model: device_model}}
    )
  end

  def verify(%{client: _} = testcase, %{client: _} = result) do
    # regular user agent
    testcase.user_agent == result.user_agent &&
      testcase.browser_family == result.browser_family &&
      testcase.os_family == result.os_family &&
      testcase.client == maybe_from_struct(result.client) &&
      testcase.device == maybe_from_struct(result.device) &&
      testcase.os == maybe_from_struct(result.os)
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def verify(testcase, result) do
    # bot
    acc = testcase.user_agent == result.user_agent && testcase.bot.name == result.name

    acc =
      if Map.has_key?(testcase.bot, :category) do
        acc && testcase.bot.category == result.category
      else
        acc
      end

    acc =
      if Map.has_key?(testcase.bot, :url) do
        acc && testcase.bot.url == result.url
      else
        acc
      end

    acc =
      if Map.has_key?(testcase.bot, :producer) do
        acc && testcase.bot.producer == maybe_from_struct(result.producer)
      else
        acc
      end

    acc
  end

  defp maybe_from_struct(:unknown), do: :unknown
  defp maybe_from_struct(result), do: Map.from_struct(result)
end
