const contractAddress = "0x6aeB9f0a47362E324350191116b61E28b7F83627";

const contractAbi = [
    {
        "inputs": [],
        "name": "get",
        "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [{ "internalType": "uint256", "name": "_value", "type": "uint256" }],
        "name": "set",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    }
];

let contract;

const connectButton = document.getElementById('connectButton');
const getButton = document.getElementById('getButton');
const setButton = document.getElementById('setButton');
const valueInput = document.getElementById('valueInput');
const valueDisplay = document.getElementById('valueDisplay');
const statusMessage = document.getElementById('statusMessage');

async function connectWallet() {
    if (typeof window.ethereum !== 'undefined') {
        try {
            connectButton.textContent = 'Wallet Connected';
            const provider = new ethers.BrowserProvider(window.ethereum);
            const signer = await provider.getSigner();
            contract = new ethers.Contract(contractAddress, contractAbi, signer);
            showMessage('Wallet connected successfully', 'success');
        } catch (error) {
            showMessage('Error: ' + error.message, 'error');
        }
    } else {
        showMessage('Please install MetaMask', 'error');
    }
}

async function getValue() {
    if (!contract) {
        showMessage('Please connect wallet first', 'error');
        return;
    }

    try {
        const value = await contract.get();
        valueDisplay.textContent = value.toString();
    } catch (error) {
        showMessage('Error: ' + error.message, 'error');
    }
}

async function setValue() {
    if (!contract) {
        showMessage('Please connect wallet first', 'error');
        return;
    }

    const newValue = valueInput.value;

    if (!newValue) {
        showMessage('Please enter a value', 'error');
        return;
    }

    try {
        showMessage('Sending transaction...', 'success');
        const tx = await contract.set(newValue);
        showMessage('Waiting for confirmation...', 'success');
        await tx.wait();
        valueInput.value = '';
    } catch (error) {
        showMessage('Error: ' + error.message, 'error');
    }
}

function showMessage(message, type) {
    statusMessage.textContent = message;
    statusMessage.className = type;
}

connectButton.addEventListener('click', connectWallet);
getButton.addEventListener('click', getValue);
setButton.addEventListener('click', setValue);