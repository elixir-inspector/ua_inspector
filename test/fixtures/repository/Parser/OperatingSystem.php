<?php

class OperatingSystem
{
    protected static $operatingSystems = [
        'DFB' => 'DragonFly',
        'BSD' => 'FreeBSD',
        'NBS' => 'NetBSD',
        'OBS' => 'OpenBSD',
        'WIN' => 'Windows',
    ];

    protected static $osFamilies = [
        'Chrome OS'  => ['COS'],
        'Firefox OS' => ['FOS', 'KOS'],
        'Windows'    => ['WIN'],
    ];

    protected static $desktopOsArray = ['Windows'];
}