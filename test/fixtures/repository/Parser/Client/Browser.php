<?php

class Browser
{
    protected static $availableBrowsers = [
        'CH' => 'Chrome',
        'FF' => 'Firefox',
        'IE' => 'Internet Explorer',
    ];

    protected static $browserFamilies = [
        'Chrome'            => ['CH', 'CM'],
        'Internet Explorer' => ['IE'],
    ];

    protected static $mobileOnlyBrowsers = [
        'CH', 'FF', 'IE',
    ];
}
