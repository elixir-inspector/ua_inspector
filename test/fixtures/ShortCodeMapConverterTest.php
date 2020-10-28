<?php

class ShortCodeMapConverterTest
{
    public static $hash = array(
        'AA' => 'A-Value',
        'BB' => 'B-Value',
        'CC' => 'C-Value'
    );

    protected static $hashWithList = array(
        'A-Value' => array('AA'),
        'B-Value' => array('BA', 'BB')
    );

    protected static $list = array('AA', 'BB');
}
