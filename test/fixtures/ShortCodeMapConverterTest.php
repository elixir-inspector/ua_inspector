<?php

class ShortCodeMapConverterTest
{
    public static $hash = [
        'AA' => 'A-Value',
        'BB' => 'B-Value',
        'CC' => 'C-Value',

        // 'DD' => 'ignored',
    ];

    public static $hashLegacy = array(
        'AA' => 'A-Value',
        'BB' => 'B-Value',
        'CC' => 'C-Value'
    );

    protected static $hashWithList = [
        'A-Value' => ['AA'],
        'B-Value' => ['BA', 'BB'],

        // 'CC' => ['ignored'],
    ];

    protected static $hashWithListLegacy = array(
        'A-Value' => array('AA'),
        'B-Value' => array('BA', 'BB')
    );

    protected static $hashWithListMultiline = [
        'A-Value' => ['AA'],
        'B-Value' => [
            'BA',
            'BB'
        ],
    ];

    protected static $list = ['AA', 'BB'];
    protected static $listLegacy = array('AA', 'BB');
    protected static $listMultiline = [
        'AA',
        'BB',

        // 'ignored',
    ];
}
