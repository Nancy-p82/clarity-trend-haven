import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can list a new product",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall(
        "trend-haven",
        "list-product",
        [
          types.utf8("Test Product"),
          types.utf8("Test Description"),
          types.uint(1000000)
        ],
        wallet_1.address
      )
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    block.receipts[0].result.expectOk().expectUint(1);
  },
});

Clarinet.test({
  name: "Can purchase a listed product",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const seller = accounts.get("wallet_1")!;
    const buyer = accounts.get("wallet_2")!;
    
    // First list a product
    let block = chain.mineBlock([
      Tx.contractCall(
        "trend-haven",
        "list-product",
        [
          types.utf8("Test Product"),
          types.utf8("Test Description"), 
          types.uint(1000000)
        ],
        seller.address
      )
    ]);

    // Then try to purchase it
    block = chain.mineBlock([
      Tx.contractCall(
        "trend-haven",
        "purchase-product",
        [types.uint(1)],
        buyer.address
      )
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectBool(true);
  },
});
