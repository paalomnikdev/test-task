<?php

namespace Panda;

class Helper
{
    protected $_partnerId = '89582';
    protected $_secretKey = 'dd252454500dd85426b6301e8a4781f5a23d17e479fa12b4fb73c406613ca7d2';

    /**
     * obtain partner id
     * @return string
     */
    public function getPartnerId()
    {
        return $this->_partnerId;
    }

    /**
     * obtain secret key
     * @return string
     */
    public function getSecretKey()
    {
        return $this->_secretKey;
    }

    /**
     * response processing
     * @param string $response
     * @return \stdClass
     */
    public function processResponse($response)
    {
        return json_decode($response);
    }
}