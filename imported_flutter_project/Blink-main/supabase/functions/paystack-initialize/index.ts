// Supabase Edge Function: paystack-initialize
// Deploy:  supabase functions deploy paystack-initialize
// Secret:  supabase secrets set PAYSTACK_SECRET_KEY=sk_live_xxx

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const PAYSTACK_SECRET_KEY = Deno.env.get("PAYSTACK_SECRET_KEY") ?? "";

serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), { status: 405 });
  }

  try {
    const { email, amount_kobo, reference, purpose } = await req.json();

    if (!email || !amount_kobo || !reference) {
      return new Response(
        JSON.stringify({ error: "email, amount_kobo and reference are required" }),
        { status: 400 },
      );
    }

    const paystackRes = await fetch("https://api.paystack.co/transaction/initialize", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${PAYSTACK_SECRET_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email,
        amount: amount_kobo,
        reference,
        metadata: { purpose },
      }),
    });

    const payload = await paystackRes.json();

    if (!payload.status) {
      return new Response(JSON.stringify({ error: payload.message ?? "Paystack init failed" }), { status: 502 });
    }

    return new Response(
      JSON.stringify({
        authorization_url: payload.data.authorization_url,
        access_code: payload.data.access_code,
        reference: payload.data.reference,
      }),
      { headers: { "Content-Type": "application/json" } },
    );
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), { status: 500 });
  }
});
