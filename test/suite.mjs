export async function suite(h) {
  const c = await h.deploy("SessionWallet", [h.addresses[0]]);
  await h.tx(h.signers[0].sendTransaction({ to: c.target, value: 1000 }));
  await h.tx(c.configureSession(h.addresses[1], 100, (await h.now()) + 100));
  await h.tx(c.setTarget(h.addresses[1], h.addresses[2], true));
  await h.test("unconfigured target rejected", () =>
    h.revert(() =>
      c.connect(h.signers[1]).execute(h.addresses[3], 10, "0x", 0),
    ),
  );
  await h.test("session call consumes budget and nonce", async () => {
    await h.tx(c.connect(h.signers[1]).execute(h.addresses[2], 60, "0x", 0));
    h.eq((await c.sessions(h.addresses[1])).spent, 60n);
  });
  await h.test("nonce replay rejected", () =>
    h.revert(() => c.connect(h.signers[1]).execute(h.addresses[2], 1, "0x", 0)),
  );
  await h.test("cumulative budget enforced", () =>
    h.revert(() =>
      c.connect(h.signers[1]).execute(h.addresses[2], 41, "0x", 1),
    ),
  );
  await h.test(
    "generation resets require fresh target authorization",
    async () => {
      await h.tx(
        c.configureSession(h.addresses[1], 100, (await h.now()) + 100),
      );
      await h.revert(() =>
        c.connect(h.signers[1]).execute(h.addresses[2], 1, "0x", 0),
      );
    },
  );
  await h.test("revocation blocks session calls", async () => {
    await h.tx(c.setTarget(h.addresses[1], h.addresses[2], true));
    await h.tx(c.revokeSession(h.addresses[1]));
    await h.revert(() =>
      c.connect(h.signers[1]).execute(h.addresses[2], 1, "0x", 0),
    );
  });
  await h.test(
    "permission view respects revoked session generation",
    async () => {
      h.eq(await c.isTargetAllowed(h.addresses[1], h.addresses[2]), false);
    },
  );
}
