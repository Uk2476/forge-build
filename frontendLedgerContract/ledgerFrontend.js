const contractAddress = '0x3195a88E104CFCA22131002816Fa2CF85e75152a';

const contractAbi = [
    {
      "type": "function",
      "name": "Credit",
      "inputs": [
        {
          "name": "transactionPurpose",
          "type": "string",
          "internalType": "string"
        },
        { "name": "creditAmount", "type": "uint256", "internalType": "uint256" }
      ],
      "outputs": [],
      "stateMutability": "nonpayable"
    },
    {
      "type": "function",
      "name": "Debit",
      "inputs": [
        {
          "name": "transactionPurpose",
          "type": "string",
          "internalType": "string"
        },
        { "name": "debitAmount", "type": "uint256", "internalType": "uint256" }
      ],
      "outputs": [],
      "stateMutability": "nonpayable"
    },
    {
      "type": "function",
      "name": "getBalance",
      "inputs": [],
      "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
      "stateMutability": "view"
    },
    {
      "type": "function",
      "name": "getTransactionAmountByPurpose",
      "inputs": [
        {
          "name": "transactionPurpose",
          "type": "string",
          "internalType": "string"
        }
      ],
      "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
      "stateMutability": "view"
    },
    {
      "type": "function",
      "name": "getTransactionDetails",
      "inputs": [
        { "name": "index", "type": "uint256", "internalType": "uint256" }
      ],
      "outputs": [
        { "name": "", "type": "string", "internalType": "string" },
        { "name": "", "type": "uint256", "internalType": "uint256" }
      ],
      "stateMutability": "view"
    },
    {
      "type": "event",
      "name": "CreditAdded",
      "inputs": [
        {
          "name": "purpose",
          "type": "string",
          "indexed": false,
          "internalType": "string"
        },
        {
          "name": "amount",
          "type": "uint256",
          "indexed": false,
          "internalType": "uint256"
        },
        {
          "name": "newBalance",
          "type": "uint256",
          "indexed": false,
          "internalType": "uint256"
        }
      ],
      "anonymous": false
    },
    {
      "type": "event",
      "name": "DebitAdded",
      "inputs": [
        {
          "name": "purpose",
          "type": "string",
          "indexed": false,
          "internalType": "string"
        },
        {
          "name": "amount",
          "type": "uint256",
          "indexed": false,
          "internalType": "uint256"
        },
        {
          "name": "newBalance",
          "type": "uint256",
          "indexed": false,
          "internalType": "uint256"
        }
      ],
      "anonymous": false
    }
];

let contract;
let provider;
let signer;

const connectButton = document.getElementById('connectButton');
const getBalanceButton = document.getElementById('getBalanceButton');
const balanceDisplay = document.getElementById('balanceDisplay');
const creditPurpose = document.getElementById('creditPurpose');
const creditAmount = document.getElementById('creditAmount');
const creditButton = document.getElementById('creditButton');
const debitPurpose = document.getElementById('debitPurpose');
const debitAmount = document.getElementById('debitAmount');
const debitButton = document.getElementById('debitButton');
const transactionIndex = document.getElementById('transactionIndex');
const getTransactionButton = document.getElementById('getTransactionButton');
const transactionDisplay = document.getElementById('transactionDisplay');
const purposeQuery = document.getElementById('purposeQuery');
const getPurposeButton = document.getElementById('getPurposeButton');
const purposeDisplay = document.getElementById('purposeDisplay');
const statusMessage = document.getElementById('statusMessage');

function showMessage(message) {
    statusMessage.textContent = message;
    setTimeout(function () {
        statusMessage.textContent = '';
    }, 5000);
}

async function connectWallet() {
    if (typeof window.ethereum !== 'undefined') {
        try {
            provider = new ethers.BrowserProvider(window.ethereum);
            signer = await provider.getSigner();
            contract = new ethers.Contract(contractAddress, contractAbi, signer);
            showMessage('Wallet connected successfully');
            connectButton.textContent = 'Wallet Connected';
        } catch (error) {
            showMessage('Error ' );
        }
    } else {
        showMessage('Please install MetaMask');
    }
}

async function getBalance() {
    if (!contract) {
        showMessage('Please connect wallet first');
        return;
    }
    try {
        const balance = await contract.getBalance();
        balanceDisplay.textContent = 'Balance: ' + balance.toString();
    } catch (error) {
        showMessage('Error ' );
    }
}

async function creditTransaction() {
    if (!contract) {
        showMessage('Please connect wallet first');
        return;
    }
    const purpose = creditPurpose.value;
    const amount = creditAmount.value;
    if (!purpose || !amount) {
        showMessage('Please fill all fields');
        return;
    }
    try {
        showMessage('Processing transaction...');
        const tx = await contract.Credit(purpose, amount);
        showMessage('Waiting to get transaction confirmation...');
        await tx.wait();
        showMessage('Credit transaction successful');
        creditPurpose.value = '';
        creditAmount.value = '';
    } catch (error) {
        showMessage('Error ');
    }
}

async function debitTransaction() {
    if (!contract) {
        showMessage('Please connect wallet first');
        return;
    }
    const purpose = debitPurpose.value;
    const amount = debitAmount.value;
    if (!purpose || !amount) {
        showMessage('Please fill all fields');
        return;
    }
    try {
        showMessage('Processing transaction...');
        const tx = await contract.Debit(purpose, amount);
        showMessage('Waiting to get transaction confirmation...');
        await tx.wait();
        showMessage('Debit transaction successful');
        debitPurpose.value = '';
        debitAmount.value = '';
    } catch (error) {
        showMessage('Error ');
    }
}

async function getTransactionDetails() {
    if (!contract) {
        showMessage('Please connect wallet first');
        return;
    }
    const index = transactionIndex.value;
    if (!index) {
        showMessage('Please enter transaction index');
        return;
    }
    try {
        const details = await contract.getTransactionDetails(index);
        transactionDisplay.textContent = 'Purpose: ' + details[0] + ', Amount: ' + details[1].toString();
    } catch (error) {
        showMessage('Error ');
    }
}

async function getAmountByPurpose() {
    if (!contract) {
        showMessage('Please connect wallet first');
        return;
    }
    const purpose = purposeQuery.value;
    if (!purpose) {
        showMessage('Please enter transaction purpose');
        return;
    }
    try {
        const amount = await contract.getTransactionAmountByPurpose(purpose);
        purposeDisplay.textContent = 'Amount: ' + amount.toString();
    } catch (error) {
        showMessage('Error ');
    }
}

connectButton.addEventListener('click', connectWallet);
getBalanceButton.addEventListener('click', getBalance);
creditButton.addEventListener('click', creditTransaction);
debitButton.addEventListener('click', debitTransaction);
getTransactionButton.addEventListener('click', getTransactionDetails);
getPurposeButton.addEventListener('click', getAmountByPurpose);