<?php

namespace Panda;

use Panda\Exception\PandaEmptyDataException;
use Panda\Exception\PandaException;

class Api
{
    protected  $_helper;
    protected $_options;
    const API_URL = 'https://mt4.pandats-api.com/api/v1/';
    const PARTNER_OPEN_OPTIONS_METHOD = 'OpenOptions';

    public function __construct()
    {
        date_default_timezone_set('UTC');
    }

    /**
     * get all partner options
     * @return array
     * @throws PandaEmptyDataException
     * @throws PandaException
     */
    public function getAllOptions()
    {
        if (null === $this->_options) {
            $helper = $this->_getHelper();
            $requestUri = $this->_buildRequestUri([], $helper->getPartnerId(), $helper->getSecretKey());
            $request = self::API_URL . self::PARTNER_OPEN_OPTIONS_METHOD . '?' . $requestUri;
            $response = $this->_executeRequest($request);
            $response = $helper->processResponse($response);

            if (!property_exists($response, 'data')) {
                throw new PandaEmptyDataException('No data received');
            }

            foreach ($response->data as $dataSet) {
                foreach ($dataSet as $options) {
                    foreach ($options as $option) {
                        if (property_exists($option, 'symbol')) {
                            $this->_options[$option->symbol][] = $option;
                        }
                    }
                }
            }
        }

        return $this->_options;
    }

    /**
     * @param string $symbol
     * @return \stdClass
     * @throws PandaEmptyDataException
     */
    public function getOptionBySymbol($symbol)
    {
        $options = $this->getAllOptions();
        if (!empty($options[$symbol])) {
            return array_slice($options[$symbol], 0, 1);
        }

        throw new PandaEmptyDataException('No data received.');
    }

    /**
     * creates uri query string
     * @param array $params
     * @param int|string $partnerId
     * @param string $partnerSecretKey
     * @return string
     */
    protected function _buildRequestUri(array $params, $partnerId, $partnerSecretKey)
    {
        $params['partnerId'] = $partnerId;
        $params['time'] = time();

        $values = array_values($params);
        sort($values, SORT_STRING);
        $string = join('', $values);
        $params['transactionKey'] = sha1($string . $partnerSecretKey);
        return http_build_query($params);
    }

    /**
     * execute request to api
     * @param string $request
     * @return string
     * @throws \Panda\Exception\PandaException
     */
    protected function _executeRequest($request)
    {
        $curl = curl_init();
        curl_setopt_array($curl, [
            CURLOPT_RETURNTRANSFER  => 1,
            CURLOPT_URL             => $request,
        ]);

        $result = curl_exec($curl);

        if (curl_error($curl)) {
            throw new PandaException(curl_error($curl));
        }

        if (curl_getinfo($curl, CURLINFO_HTTP_CODE) !== 200) {
            throw new PandaException($result);
        }

        return $result;
    }

    /**
     * gives helper instance
     * @return \Panda\Helper
     */
    protected function _getHelper()
    {
        if (null === $this->_helper) {
            $this->_helper = new Helper();
        }

        return $this->_helper;
    }
}
