const express = require('express');
const Razorpay = require('razorpay');
const bodyParser = require('body-parser');
const app = express();
app.use(bodyParser.json());

const razorpay = new Razorpay({
    key_id: 'rzp_test_ajzWxbRdWdbBA4', // Razorpay key ID
    key_secret: '1KYsNDHr5i7DqLAloNKGR2SH' // Razorpay key secret
});

app.post('/refund', async (req, res) => {
    try {
        const { paymentId, amount } = req.body;

        // Initiate the refund
        const refund = await razorpay.refunds.create({
            payment_id: paymentId,
            amount: amount, // Amount in paise
            notes: { reason: 'Booking Cancellation' }
        });

        res.json({ status: 'processed', refund });
    } catch (error) {
        console.error(error);
        res.status(500).json({ status: 'failed', error: error.message });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
