<?php
spl_autoload_register(function($class) {
    $path = str_replace('\\', DIRECTORY_SEPARATOR, $class);
    require_once __DIR__ . DIRECTORY_SEPARATOR . $path . '.php';
});

$pandaApi = new Panda\Api();

try {
    $pandaApi->getAllOptions();
    $pandaApi->getOptionBySymbol('AUDJPY');
} catch (\Panda\Exception\PandaEmptyDataException $e) {
    echo $e->getMessage();
    exit;
} catch (\Panda\Exception\PandaException $e) {
    echo $e->getMessage();
    exit;
} catch (Exception $e) {
    echo $e->getMessage();
    exit;
}