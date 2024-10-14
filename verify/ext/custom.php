<?php declare(strict_types=1);

use DeviceDetector\ClientHints;
use DeviceDetector\DeviceDetector;
use DeviceDetector\Parser\Device\AbstractDeviceParser;
use PHPUnit\Framework\Assert;

require_once 'device-detector/vendor/autoload.php';

$fixtures = [];
$fixtureFiles = \glob(\realpath(__DIR__) . '/../fixtures/*.yml');

foreach ($fixtureFiles as $fixturesPath) {
    $fixtureEntries = \Spyc::YAMLLoad($fixturesPath);
    $fixtures = \array_merge(\array_map(static function ($elem) {
        return [$elem];
    }, $fixtureEntries), $fixtures);
}

AbstractDeviceParser::setVersionTruncation(AbstractDeviceParser::VERSION_TRUNCATION_NONE);

foreach ($fixtures as $fixtureEntries) {
    foreach ($fixtureEntries as $fixtureEntry) {
        $ua = $fixtureEntry['user_agent'];
        $clientHints = !empty($fixtureEntry['headers']) ? ClientHints::factory($fixtureEntry['headers']) : null;

        try {
            $uaInfo = DeviceDetector::getInfoFromUserAgent($ua, $clientHints);
        } catch (\Exception $exception) {
            throw new \Exception(
                \sprintf('Error: %s from useragent %s', $exception->getMessage(), $ua),
                $exception->getCode(),
                $exception
            );
        }

        $errorMessage = \sprintf(
            "UserAgent: %s\nHeaders: %s",
            $ua,
            \print_r($fixtureEntry['headers'] ?? null, true)
        );

        unset($fixtureEntry['headers']); // ignore headers in result

        Assert::assertEquals($fixtureEntry, $uaInfo, $errorMessage);
    }
}
