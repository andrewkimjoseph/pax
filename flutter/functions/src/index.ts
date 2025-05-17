
import { initializeApp } from 'firebase-admin/app';

initializeApp();


export { createPrivyServerWallet } from './createPrivyServerWallet';
export { createPaxAccountV1Proxy } from './createPaxAccountV1Proxy';
export { withdrawToPaymentMethod } from './withdrawToPaymentMethod';