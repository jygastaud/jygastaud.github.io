+++
title = "Contactez moi"
+++

<article id="main">

  <header class="special container">
    <span class="icon fa-envelope"></span>
    <h2>Vous avez un projet?</h2>
    <p>Alors parlons en!</p>
  </header>

  <!-- One -->
    <section class="wrapper style4 special container 75%">

      <!-- Content -->
        <div class="content">
          <div class="ui error message"></div>
          <form name="form--contact" id="form--contact" class="ui form">
            <div class="row 50%">
              <div class="12u">
                <input type="email" name="email" id="email" placeholder="Email" required>
              </div>
            </div>
            <div class="row 50%">
              <div class="12u">
                <input type="text" name="subject" id="subject" placeholder="Subject" required>
              </div>
            </div>
            <div class="row 50%">
              <div class="12u">
                <textarea name="message" id="message" placeholder="Message" required rows="7"></textarea>
              </div>
            </div>
            <div class="row">
              <div class="12u">
                <ul class="buttons">
                  <li><input type="submit" class="ui submit button special" value="Send Message" onClick="sendMail()" /></li>
                </ul>
              </div>
            </div>
          </form>
        </div>

    </section>

</article>
