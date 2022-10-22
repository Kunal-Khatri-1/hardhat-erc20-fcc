// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface tokenReceipt {
    function receiveApproval(
        address _from,
        uint256 _value,
        address _token,
        bytes calldata _extraData
    ) external;
}

contract ManualToken {
    /* Storage Variables */
    string public name;
    string public symbol;
    uint8 public constant DECIMALS = 18;
    // how many tokens are there in the beginning
    // sometimes there will be mint functions to add more tokens
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    // allowances => who is allowed which address to take how much tokens
    // transferFrom will check this allowance mapping to check if Alice gave Authorization to Bob to borrow XYZ tokens
    // approve function to update allowance
    mapping(address => mapping(address => uint256)) public allowance;

    /* Events */
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
    // noftify the client about the amount of coins burnt
    event Burn(address indexed from, uint256 value);

    /* Constructor Function
        initialSupply tokens will be initialized to deployer of the contract */
    constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) {
        totalSupply = initialSupply * 10**uint256(DECIMALS);
        balanceOf[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
    }

    // Transfer tokens
    // subtract from address amount and add to to address
    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) internal {
        // prevent transfer to address(0)
        require(_to != address(0x0));
        // sender must have enough balance
        require(balanceOf[_from] >= _value);
        // overflow check
        require(balanceOf[_to] + _value >= balanceOf[_to]);

        uint256 previousBalance = balanceOf[_from] + balanceOf[_to];

        // subtract _value from sender
        balanceOf[_from] -= _value;
        // add _value to the recipient
        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);

        // checking bugs
        assert(balanceOf[_from] + balanceOf[_to] == previousBalance);
    }

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        _transfer(msg.sender, _to, _value);

        return true;
    }

    // allow smart contract / someone else to work with our token => approve function that will approve the contract to do that
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        // implement taking funds from the user
        require(_value <= allowance[_from][msg.sender]); // checking for allowance for authorization

        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);

        return true;
    }

    /* allows _spender to spend no more than _value tokens on your behalf
        _extraData some data sent to approved contract */
    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function approvaAndCall(
        address _spender,
        uint256 _value,
        bytes memory _extraData
    ) public returns (bool success) {
        tokenReceipt spender = tokenReceipt(_spender);

        if (approve(_spender, _value)) {
            spender.receiveApproval(
                msg.sender,
                _value,
                address(this),
                _extraData
            );

            return true;
        }
    }

    /* Destroy tokens from account */
    function burn(uint256 _value) public returns (bool success) {
        // transaction sender must have enough balance
        require(balanceOf[msg.sender] >= _value);

        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;

        emit Burn(msg.sender, _value);

        return true;
    }

    /* Destroy tokens from other account */
    function burnFrom(address _from, uint256 _value)
        public
        returns (bool success)
    {
        // checking for permission
        require(_value <= allowance[_from][msg.sender]);

        // subtract from the _from account
        balanceOf[_from] -= _value;
        // decrease amount msg.sender can use from _from account
        allowance[_from][msg.sender] -= _value;
        // decreasing the total supply
        totalSupply -= _value;

        emit Burn(_from, _value);

        return true;
    }
}
