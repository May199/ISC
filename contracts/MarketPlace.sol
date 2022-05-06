// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract MarketPlace {
  string public name;
  uint public productCount = 0;

  mapping(uint => Product) public products;

  struct Product {
    uint id;
    string name;
    uint price;
    address payable owner;
    bool purchased;
  }

  event ProductCreated(
    uint id,
    string name,
    uint price,
    address payable owner,
    bool purchased
  );

  event ProductSeller(
    uint id,
    string name,
    uint price,
    address payable owner,
    bool purchased
  );

  constructor() {
    name = "Vendedor Obscuro";
  }

  function createProduct(string memory _name, uint _price) public {
    // Nome válido obrigatório
    require(bytes(_name).length > 0);
    // Preço válido obrigatório
    require(_price > 0);
    // Aumentar a contagem de produtos
    productCount ++;
    // Criar um produto
    products[productCount] = Product(productCount, _name, _price, payable(msg.sender), false);
    // Acionar a entrada
    emit ProductCreated(productCount, _name, _price, payable(msg.sender), false);
  }

  function purchaseProduct(uint _id) public payable {
    // Pegue o produto
    Product memory _product = products[_id];
    // Buscar o proprietário
    address payable _seller = _product.owner;
    // Verifique se o produto tem um ID válido
    require(_product.id > 0 && _product.id <= productCount);
    // Verifique se tem Ether suficiente na transação
    require(msg.value >= _product.price);
    // Verifique o produto não ser adquirido antes
    require(!_product.purchased);
    // Verifique se o vendedor não pode comprar seu próprio produto
    require(_seller != msg.sender, "Seller can't buy his own product");
    // Transferir a propriedade para o comprador
    _product.owner = payable(msg.sender);
    // Marcar como compra
    _product.purchased = true;
    // Atualize o produto
    products[_id] = _product;
    // Pague o vendedor
    payable(_seller).transfer(msg.value);
    // Acionar o evento
    emit ProductSeller(productCount, _product.name, _product.price, payable(msg.sender), true);

  }

}
