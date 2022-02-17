<?php

class Browser
{
    protected static $availableBrowsers = array(
        'CH' => 'Chrome',
        'FF' => 'Firefox',
        'IE' => 'Internet Explorer'
    );

    protected static $browserFamilies = array(
        'Chrome'            => array('CH', 'CM'),
        'Internet Explorer' => array('IE')
    );

    protected static $mobileOnlyBrowsers = array(
        'CH', 'FF', 'IE'
    );
}
