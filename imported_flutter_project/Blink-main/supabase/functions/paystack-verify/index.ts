// Supabase Edge Function: paystack-verify
// Deploy: supabase functions deploy paystack-verify
// Reuses the same PAYSTACK_SECRET_KEY secret as paystack-initialize.

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const PAYSTACK_SECRET_KEY = Deno.env.get("PAYSTACK_SECRET_KEY") ?? "";

serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), { status: 405 });
  }

  try {
    const { reference } = await req.json();
    if (!reference) {
      return new Response(JSON.stringify({ error: "reference is required" }), { status: 400 });
    }

    const paystackRes = await fetch(`https://api.paystack.co/transaction/verify/${reference}`, {
      headers: { Authorization: `Bearer ${PAYSTACK_SECRET_KEY}` },
    });

    const payload = await paystackRes.json();
    const verified = payload.status === true && payload.data?.status === "success";

    return new Response(
      JSON.stringify({ verified, amount: payload.data?.amount, currency: payload.data?.currency }),
      { headers: { "Content-Type": "application/json" } },
    );
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err), verified: false }), { status: 500 });
  }
});
