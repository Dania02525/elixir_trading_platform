<template>
  <div class="bs-component">
    <ul class="nav nav-tabs">
      <li class="nav-item">
        <a class="nav-link active" data-toggle="tab" href="#buy">Buy XRB</a>
      </li>
      <li class="nav-item">
        <a class="nav-link" data-toggle="tab" href="#sell">Sell XRB</a>
      </li>
    </ul>
    <div id="myTabContent" class="tab-content">
      <div class="tab-pane fade show active" id="buy">
        <div class="price-box-balance">
          XLM Balance: 12455
        </div>
        <div class="form-group row">
          <div class="col-2">
            Price
          </div>
          <div class="col-6">
            <div class="input-group mb-2">
              <input type="text" id="price" class="form-control" aria-label="Price">
              <div class="input-group-append">
                <a class="input-group-text" href="#">Market</a>
              </div>
            </div>
          </div>
        </div>
        <div class="form-group row">
          <div class="col-2">
            Amount
          </div>
          <div class="col-6">
            <div class="input-group mb-2">
              <input type="text" class="form-control" aria-label="Amount">
              <div class="input-group-append">
                <span class="input-group-text">Max</span>
              </div>
            </div>
          </div>
        </div>
        <div class="row">
          <button type="button" class="btn btn-outline-success">Place Limit Order</button>
        </div>
      </div>
      <div class="tab-pane fade" id="sell">
        <div class="price-box-balance">
          XRB Balance: 878
        </div>
        <div class="form-group price-input row">
          <div class="col-2">
            Price
          </div>
          <div class="col-6">
            <div class="input-group mb-2">
              <input type="text" id="price" class="form-control" aria-label="Price">
              <div class="input-group-append">
                <a class="input-group-text" href="#">Market</a>
              </div>
            </div>
          </div>
        </div>
        <div class="form-group price-input row">
          <div class="col-2">
            Amount
          </div>
          <div class="col-6">
            <div class="input-group mb-2">
              <input type="text" id="quantity" class="form-control" aria-label="Quantity">
              <div class="input-group-append">
                <a class="input-group-text" href="#">Max</a>
              </div>
            </div>
          </div>
        </div>
        <div class="row">
          <button type="button" class="btn btn-outline-success">Place Limit Order</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  export default {

  }
</script>
