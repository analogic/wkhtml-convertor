<?php

try {
    $type = substr($_SERVER['SCRIPT_NAME'], 1);
    $url = $_SERVER['QUERY_STRING'];

    if (empty($type)) {
        throw new \Exception('Missing output type');
    }
    if (empty($url)) {
        throw new \Exception('Missing URL');
    }
    if (!preg_match('~^http~i', $url)) {
        throw new \Exception('Only HTTP URLs allowed');
    }
    if (!in_array($type, ['img', 'pdf'])) {
        throw new \Exception('Not valid output type');
    }


    $cmd = $type == 'img' ? '/usr/local/bin/wkhtmltoimage -f png' : '/usr/local/bin/wkhtmltopdf';
    $file = tempnam('/tmp', 'wkhtml-');
    $ctype = $type == 'img' ? 'Content-Type: image/png' : "Content-type:application/pdf";

    $output = exec('/usr/bin/timeout 20s ' . $cmd . ' ' . escapeshellarg($url) . ' ' . $file);

    if (!is_file($file)) {
        throw new \Exception("Output file was not generated, something happend :(\nwkhtml output:\n".$output);
    }

    header($ctype);
    die(file_get_contents($file));

} catch(\Exception $e) {
    header("HTTP/1.0 400 Bad request");
    echo $e->getMessage();
}