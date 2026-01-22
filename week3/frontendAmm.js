import { createWalletClient, createPublicClient, custom, formatEther, parseEther } from 'https://esm.sh/viem';
import { sepolia } from 'https://esm.sh/viem/chains';

const CONTRACT_ADDRESS = '0x529bfC8258b4c89E37d980C1333b6b187F60819f';
const STUDYPOINT_ADDRESS = '0x916dC4B7DAb64c1F77E749B1b6239037eD1483aC';

const AMM_ABI = [
{ "type": "constructor", "inputs": [], "stateMutability": "nonpayable" },
    {
      "type": "function",
      "name": "balanceOfCt",
      "inputs": [],
      "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
      "stateMutability": "view"
    },
    {
      "type": "function",
      "name": "balanceOfSp",
      "inputs": [],
      "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
      "stateMutability": "view"
    },
    {
      "type": "function",
      "name": "canteenToken",
      "inputs": [],
      "outputs": [
        {
          "name": "",
          "type": "address",
          "internalType": "contract CanteenToken"
        }
      ],
      "stateMutability": "view"
    },
    {
      "type": "function",
      "name": "getOutputAmount",
      "inputs": [
        { "name": "Sptoken", "type": "uint256", "internalType": "uint256" }
      ],
      "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
      "stateMutability": "view"
    },
    {
      "type": "function",
      "name": "initialToken",
      "inputs": [],
      "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
      "stateMutability": "view"
    },
    {
      "type": "function",
      "name": "liquidityPool",
      "inputs": [],
      "outputs": [{ "name": "", "type": "uint256", "internalType": "uint256" }],
      "stateMutability": "view"
    },
    {
      "type": "function",
      "name": "mint",
      "inputs": [],
      "outputs": [],
      "stateMutability": "nonpayable"
    },
    {
      "type": "function",
      "name": "studyPoint",
      "inputs": [],
      "outputs": [
        { "name": "", "type": "address", "internalType": "contract StudyPoint" }
      ],
      "stateMutability": "view"
    },
    {
      "type": "function",
      "name": "swapSpwithCt",
      "inputs": [
        {
          "name": "SpToBeSwappedWithCt",
          "type": "uint256",
          "internalType": "uint256"
        }
      ],
      "outputs": [],
      "stateMutability": "nonpayable"
    },
    { "type": "error", "name": "amm_InsufficientLiquidity", "inputs": [] },
    { "type": "error", "name": "amm_insufficientBalance", "inputs": [] },
    { "type": "error", "name": "amm_onlyRecieveOnetime", "inputs": [] },
    { "type": "error", "name": "amm_transactionFAiled", "inputs": [] }
];

const ERC20_ABI = [
  {
    inputs: [
      {internalType: 'address', name: 'spender', type: 'address'},
      {internalType: 'uint256', name: 'amount', type: 'uint256'}
    ],
    name: 'approve',
    outputs: [{internalType: 'bool', name: '', type: 'bool'}],
    stateMutability: 'nonpayable',
    type: 'function'
  }
];

let walletClient;
let publicClient;
let userAddress;

const connectBtn = document.getElementById('connect-btn');
const mintBtn = document.getElementById('mint-btn');
const approveBtn = document.getElementById('approve-btn');
const swapBtn = document.getElementById('swap-btn');
const refreshBtn = document.getElementById('refresh-btn');
const connectPage = document.getElementById('connect-page');
const attendancePage = document.getElementById('attendance-page');
const swapPage = document.getElementById('swap-page');
const addressDisplay = document.getElementById('address-display');
const swapAddressDisplay = document.getElementById('swap-address-display');
const spBalanceEl = document.getElementById('sp-balance');
const ctBalanceEl = document.getElementById('ct-balance');
const swapInput = document.getElementById('swap-input');
const approveInput = document.getElementById('approve-input');
const outputAmountEl = document.getElementById('output-amount');
const attendanceMessage = document.getElementById('attendance-message');
const swapMessage = document.getElementById('swap-message');

connectBtn.addEventListener('click', connectWallet);
mintBtn.addEventListener('click', handleMint);
approveBtn.addEventListener('click', handleApprove);
swapBtn.addEventListener('click', handleSwap);
refreshBtn.addEventListener('click', loadBalances);
swapInput.addEventListener('input', handleSwapInputChange);

async function connectWallet() {
  try {
    if (!window.ethereum) {
      alert('Please install MetaMask');
      return;
    }
    await window.ethereum.request({ 
      method: 'eth_requestAccounts' 
    });
    walletClient = createWalletClient({
      chain: sepolia,
      transport: custom(window.ethereum)
    });
    publicClient = createPublicClient({
      chain: sepolia,
      transport: custom(window.ethereum)
    });
    const accounts = await walletClient.getAddresses();
    userAddress = accounts[0];
    addressDisplay.textContent = `Connected: ${userAddress.slice(0, 6)}...${userAddress.slice(-4)}`;
    swapAddressDisplay.textContent = `Connected: ${userAddress.slice(0, 6)}...${userAddress.slice(-4)}`;
    connectPage.classList.add('hidden');
    attendancePage.classList.remove('hidden');
  } catch (error) {
    console.error('Connection error:', error);
    alert('Failed to connect wallet: ' + error.message);
  }
}

async function handleMint() {
  try {
    setLoading(mintBtn, true);
    hideMessage(attendanceMessage);
    const hash = await walletClient.writeContract({
      address: CONTRACT_ADDRESS,
      abi: AMM_ABI,
      functionName: 'mint',
      account: userAddress
    });
    await publicClient.waitForTransactionReceipt({ hash });
    showMessage(attendanceMessage, 'Tokens minted successfully');
    setTimeout(() => {
      attendancePage.classList.add('hidden');
      swapPage.classList.remove('hidden');
      loadBalances();
    }, 1500);
  } catch (error) {
    console.error('Mint error:', error);
    showMessage(attendanceMessage, 'Minting failed: ' + error.message);
  } finally {
    setLoading(mintBtn, false);
  }
}

async function loadBalances() {
  try {
    const spBalance = await publicClient.readContract({
      address: CONTRACT_ADDRESS,
      abi: AMM_ABI,
      functionName: 'balanceOfSp',
      args: [],
      account: userAddress
    });
    const ctBalance = await publicClient.readContract({
      address: CONTRACT_ADDRESS,
      abi: AMM_ABI,
      functionName: 'balanceOfCt',
      args: [],
      account: userAddress
    });
    spBalanceEl.textContent = `${parseFloat(formatEther(spBalance)).toFixed(2)} SP`;
    ctBalanceEl.textContent = `${parseFloat(formatEther(ctBalance)).toFixed(2)} CT`;
  } catch (error) {
    console.error('Failed to load balances:', error);
  }
}

async function handleSwapInputChange(e) {
  const amount = e.target.value;
  if (!amount || amount === '0') {
    outputAmountEl.textContent = '0 CT';
    return;
  }
  try {
    const amountInWei = parseEther(amount);
    const output = await publicClient.readContract({
      address: CONTRACT_ADDRESS,
      abi: AMM_ABI,
      functionName: 'getOutputAmount',
      args: [amountInWei]
    });
    outputAmountEl.textContent = `${parseFloat(formatEther(output)).toFixed(4)} CT`;
  } catch (error) {
    outputAmountEl.textContent = '0 CT';
  }
}

async function handleApprove() {
  try {
    const amount = approveInput.value;
    if (!amount) return;
    setLoading(approveBtn, true);
    hideMessage(swapMessage);
    const amountInWei = parseEther(amount);
    const hash = await walletClient.writeContract({
      address: STUDYPOINT_ADDRESS,
      abi: ERC20_ABI,
      functionName: 'approve',
      args: [CONTRACT_ADDRESS, amountInWei],
      account: userAddress
    });
    await publicClient.waitForTransactionReceipt({ hash });
    showMessage(swapMessage, 'Approval successful');
  } catch (error) {
    console.error('Approve error:', error);
    showMessage(swapMessage, 'Approval failed: ' + error.message);
  } finally {
    setLoading(approveBtn, false);
  }
}

async function handleSwap() {
  try {
    const amount = swapInput.value;
    if (!amount) return;
    setLoading(swapBtn, true);
    hideMessage(swapMessage);
    const amountInWei = parseEther(amount);
    const hash = await walletClient.writeContract({
      address: CONTRACT_ADDRESS,
      abi: AMM_ABI,
      functionName: 'swapSpwithCt',
      args: [amountInWei],
      account: userAddress
    });
    await publicClient.waitForTransactionReceipt({ hash });
    showMessage(swapMessage, 'Swap successful');
    swapInput.value = '';
    outputAmountEl.textContent = '0 CT';
    setTimeout(() => loadBalances(), 2000);
  } catch (error) {
    console.error('Swap error:', error);
    showMessage(swapMessage, 'Swap failed: ' + error.message);
  } finally {
    setLoading(swapBtn, false);
  }
}

function setLoading(btn, loading) {
  if (loading) {
    btn.disabled = true;
    btn.textContent = 'Processing...';
  } else {
    btn.disabled = false;
    btn.textContent = btn.id === 'mint-btn' ? 'Yes' : btn.id === 'approve-btn' ? 'Approve' : btn.id === 'swap-btn' ? 'Swap' : 'Refresh Balances';
  }
}

function showMessage(el, text) {
  el.textContent = text;
  el.classList.remove('hidden');
}

function hideMessage(el) {
  el.classList.add('hidden');
}