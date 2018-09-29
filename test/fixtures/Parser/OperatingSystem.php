<?php

class OperatingSystem
{
    protected static $operatingSystems = array(
        'DFB' => 'DragonFly',
        'BSD' => 'FreeBSD',
        'NBS' => 'NetBSD',
        'OBS' => 'OpenBSD'
    );

    protected static $osFamilies = array(
        'Chrome OS'  => array('COS'),
        'Firefox OS' => array('FOS', 'KOS')
    );
}
