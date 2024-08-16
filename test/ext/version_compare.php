<?php declare(strict_types=1);

$source = realpath(dirname(__DIR__) . "/fixtures/versions.txt");
$specs = file($source);

foreach ($specs as $spec) {
    [$v1, $op, $v2] = explode(" ", trim($spec));

    echo "Compare: {$v1} {$op} {$v2}" . PHP_EOL;

    if (version_compare($v1, $v2, $op)) {
        continue;
    }

    throw new RuntimeException(sprintf(
        "Version comparison failed: %s %s %s",
        $v1,
        $op,
        $v2
    ));
}
