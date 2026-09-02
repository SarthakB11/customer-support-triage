// Code node for the faq-ingest flow. Hardcodes the 5 FAQ entries (same as faq/faq.json).
const faq = [
  {
    id: "faq-1",
    title: "Login fails or password reset email never arrives",
    text: "If you cannot log in, use 'Forgot password' on the sign-in page. Reset emails come from no-reply@example.com and can take up to 5 minutes; check spam. If the link says 'expired', request a new one. Still stuck: reply with your account email and the browser you are using.",
  },
  {
    id: "faq-2",
    title: "Refund policy",
    text: "We refund any monthly charge within 14 days of the charge date, no questions asked. Annual plans are refunded pro-rata for unused months. Refunds go back to the original card in 5-10 business days.",
  },
  {
    id: "faq-3",
    title: "Invoices and changing the billing email",
    text: "Invoices are under Settings > Billing > Invoices, and are also emailed to the billing contact on the 1st of each month. To change the billing contact or add a VAT/GST number, edit the fields under Settings > Billing > Company details.",
  },
  {
    id: "faq-4",
    title: "Requesting a feature",
    text: "We track feature requests in our public roadmap. Tell us the problem you are solving, not just the feature, and how often you hit it. Requests with a clear use case are prioritised. We do not promise dates.",
  },
  {
    id: "faq-5",
    title: "Reporting a bug and checking system status",
    text: "Before reporting, check status.example.com for ongoing incidents. When reporting, include: what you did, what you expected, what happened, the time (with timezone), and a screenshot or the request ID from the error banner. Bugs affecting data or payments are treated as P1.",
  },
];

output = {
  texts: faq.map((f) => `${f.title}. ${f.text}`),
  metadata: faq.map((f) => ({ id: f.id, title: f.title, text: f.text })),
};
