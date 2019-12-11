# frozen_string_literal: true

class Client::Desktop < Client::Base
  def post(uri, query = {}, headers = {})
    super(inject_global(uri), query, headers)
  end

  def get(uri, parameters = [], referer = nil, headers = {})
    super(inject_global(uri), parameters, referer, headers)
  end

  def inject_global(uri)
    uri = inject_base(uri) unless uri.include?('http')
    uri
  end

  def inject_base(uri)
    "https://#{Account.main.world}.tribalwars.com.br#{uri}"
  end

  def login
    logger.info('Making desktop login'.on_blue)
    account = Account.main
    login_page = get('https://www.tribalwars.com.br')
    headers = {}
    headers['X-CSRF-Token'] = login_page.search('meta[name=csrf-token]').attr('content').text
    headers['Content-Type'] = 'application/x-www-form-urlencoded'
    headers['X-Requested-With'] = 'XMLHttpRequest'

    # world_select_page
    post('https://www.tribalwars.com.br/page/auth', {
           username: account.username,
           password: account.password,
           remember: 1,
           token: get_token(login_page)
         }, headers)
    result = get("https://www.tribalwars.com.br/page/play/#{account.world}")
    Session.create(account, cookies, 'desktop')
  end

  def get_token(page)
    token_client = Mechanize.new
    initial_url = page.search('script[src*=recaptcha]').first.attr('src')
    initial_js = token_client.get(initial_url)
    recaptcha_script_uri = initial_js.body.scan(/http.*?releases.+?.js/).first
    recaptcha_script = token_client.get(recaptcha_script_uri)

    params = {}
    params[:v] = recaptcha_script_uri.scan(%r{releases/(.+?)/}).first.first

    post_content = %(v=PRkVene3wKrZUWATSylf69ja&reason=q&c=03AOLTBLQ6q-csNzj7vVnILOVuonS8Q5V_SAsiR6acODUTo-LExLjd3FfRVJ9lzl2zp-bUGVmC69VvkerRnQc6zkeXdbdzyAH3biJ6orSP0pHQjwd0t4vSAyJEreIjtfreAkZ2b-FQulmDaSSFfJKxl2e4Ls74dyA4OKxA3fsL0VkWuIDrCw4POM0-n9z6Ue4_eZer-vnxxF8rKBBRa1z-IBV_HFVCLEoBVqSVSs_kgK5jADGH8Sdq8pvSux8u_e_yVBPGJvOYxOmFsd-GKn_ffBDoB-4AeaLi10pmshk1ncytxY2xgNvfz7DdOMR6Tg8zHdVRTs3cd2jSGD2wFoc8YmW5tXAPDIy1dy8LzVL6SgrstoUWyCSWQ4D_KZumY0yNDDlJ9eDn9_I7jeoPsGx3-6IrW4nfgER1_A&k=6Lfu78QUAAAAANSlpg06hD6SAxv02IVqDTLrhLiq&co=aHR0cHM6Ly93d3cudHJpYmFsd2Fycy5jb20uYnI6NDQz&hl=pt-BR&size=invisible&sa=login&chr=%5B39%2C26%2C38%5D&vh=-1237264474&bg=!mZ-gn75HZ7wzHp11MWFd7YVG8glZX30HAAABElcAAAFPnAt0LotKh__rBEAFqY-_N-cvkX3Cik7g_wQqxu4JH6KJzEoa8MnUo6oiHwhwETeDenYNQkCCqOuAj1-SAOO3E7kAyP3oWozmI8iKNRUq0aBy66SkTSz0ul8SXX4rZzpo7age2jHTHSdDBjn1OfWWuXiGtdwMIp-QlGmDvNaLVkrhc1XilzatFunEsjGZM6m0eV8rhQqJfAIiKt9I5cuWAeyjnhoXVvDH8U_ePusr22WTvfM6a5nFzdbP_k8G_41sxlrAxzT63x1oJkGaMUH0e2ELmJHNOzcduwwDGnHghD7MTzRNw6EUDtc975ad5_1_bl_HpXmtZSICWsJl8vUo_9sZflUX0BPdCbYB9gNdyEbSXTG_hZy-ReJLrfFA0TzGyufFpNBAFNSubYRXPP1bN9vmMPqBIJBZnRlVuYvI_yrfZklqfJncQNtlnMCoTwx_tBOsGtDWCWuFpeFMxDaWuz5-o14-P-jW1fnPl-9OTOSUcrq9ypqZ3h3gJ9BXKLxMfIlP5T5pTccu1j388jfhX57mMOT_Azo_fheNWq5O2mTa-5v6Wkck1uctvYoGukvcGAhVj3DveKktXxfDvuaqEsLoBR1OZ-TScSw56tQ1usKpz6AN76PIQkdYsZ9zI_aSv0-62k3Bl_XRTcCGQMC7qmWT6mLuWej0mumarwC8vuyEAPJsdx_Z0BRFaQNioqwVnGbYkF8GPqV2Et5PkoliDdacRPRhReH2Sj6Cci9AwX4dh77GpRjXtJZqWirWBRvEL8D1tfSpJwKiiMqV1HpROshGxXn6mveHzLuLUD1uaBjffeuL37OpOBG4Pk94x9cUvgGTV5Bs08xINMUySJxqjWVUExGCmkZgu425uqzKHPpMm_H7BI8Ip-gWqEMIjvkwbEKbk9aEEfmB4U17CGvAVzLQUW3XWAEfv4cJ3uJT8MJHmyZtD4Hc_jutgO9ge9TA_nQ8n7105X1hiGUMs3nsDOTURv0CKuyFRgLsoFPG-AqFhVxNKZfucBsDbCe_1D7MMhfVUHN6qTXpweh0daQdlVOsLh-htvzgP0P763JVO7tFtQ-HJs9Tir23cfsqh9qaDAHXFD6crlEb3QSA-jpzFneISRMSWDO91rvWNRwgYoXnVIDNG0frmazjIVKJK7Ekha-9LMDbjh0S39PNQUVnfia62SrgJmVa14RBHinTTj2mm7gYytrwQONfg-X7lc67FohnFGo3ToZLsy-7sM80NhQf2Yrbb1I7aAN_m9nAMATIupNSxo2K9hPvOrMtN5TmRdOBStaYPsG7W52J7CjzHdh5QYkUKA86huOYJspz04XBcBkgttRIsgitmdHyZGO_So15PXzp_a-qX2RCYFec0zNkyzv9g9GU_G9QX5xpuK5_wyV6Aak0l8zkcgu8ugyD6lIsstfc4bcFWwB7BqCLj9ShH8aIYXIa7PQQDvijF35-nstclv2V6Vx8xHnlEZacVfVyFqoAMgi1tNUJ92sCUeUV3IbfMDbFEfaSplP4KJWC6cvgOXpITXn4DjnN4sDOttqzG1c9xad6scmgmKhtY_d7AdUB9tD90Za_2O4zKHCIxM5DJ775_V-quQUf94ERw7GoloXhwjSuIXh2_a7bTptt5AkLjxJ3EoTBuwhmSPY53cHQ2xAboYMBbRH-rqwikihd4o97oVbi7t-ZSTZPimhev5QHaVFwThw34pARzmbfCflZYkF6M1B9muYXcEFaG3TzAEmt_c1yrgYBjbB9WnMRo6wuItAHtXV_S3KyEPsLZk8Q6O1cSXCE6xVCxQ8UwPMgoh8XBm28DvaNLmGWrzoLY5bSGn4Djozg7e4uD9r3ziaIt29mK8cCbU9NdPXm8xpHy9PzILDHv4HPvEIluXUo16CiawSNtsZx2mt3ZxsdiFI4bkZKy-spSy2ryH2itqLIXNEyTbIx8zxKg-mDZeeYk8UBBpLS0eGUJoZxoUehBiIYi-kw50lkPPh6qeKKsPtKp7PxJfUefx9mUuzeJNTlU2SSmje9eKGK0Vrqdd-yo88ejYZqyCxcbYdTAvxSOxj47_CboVMv_xEfgFfSja-ECo2uYTf6aRxyAPR_Y3W4Kb4gsPMH-ZS9KsN5qIURo2KKh9CONgGLmDpLWWSYimzM516oUZiH17_5DIyjhVBXySYAEMIk5PZqnFSL9sy23WqcKmNaCpc-VSTNkzINhHmrl10HiAcoP6hAUnd_DjcghTxphke26iLa9quTX1V3hDclRUYoWhAIdYINk5ejQtRcjpzeH7wYElDx6Wnny_wYtfc9dMpgGNT--Hefv0Fe3qYGPgQHV_tDSPvN_O-xLRv3olXWdVjR7fvCCZXslpBfznpmcct_6511qwMXeyXRTQz5u07C34P8boDgrA_dEP_ChwKsZmLD5i-SwqA85ZBk44czCYQ7CI5015ZXOdmK3mF0C-ifU3QKd0l5aKtS_tPUy2mb4s4pCIlyQ8yPc5KYPn3M8j2vH4OW79PpQNjwsORviZEKu6XgfQkkWoXpsh7b2mpxUp85h3gNYYJHqzGXdAuFY1FYPwU3dlzRxxTNikzz3O3virvpROL4bYMTqCsK0gVVZ9zaHLSPPB2k4BR8gLspq4Lc9_zN5M8V7lYmiyx2hJiFY4b_6SXvXsi2-gE_9divQEb5ObER0A-Hgi5ntdefROFaxM1ctObyVRB5_g12x8fBlrUFtUoKoJu2LGwW-PGDn4nwODgM8P-x6S3agfN3dtbWiGnlr2Z9BEHRXEDxMQLA3nqmYkRKvEJDAPSi4T54WSDrZskbRq4V4uP3dvw5UmTtBecV9JOKK_pCe-o130aMyyPeyrkpz1BO5bMziO4l1J-f-jo1KV4YmhfkHcifwbkn3lAzrLenifC8KhcoGUqcsVgMg76YoIx8f1dpz_HosGg_vX4jW-W664J4nQBNBWkPeAPS4rNLobUimTroj2nsfUcM6N_Er4givA9sa7c74Z8B--6ooBBrew-85rhNzVctib0T-C2OWtuXTjujvKx-WbXs7RxpoBIkhFqki_BiH2c3GNgfao4KCbfgNLCmsPjZIW4P-AAPdD7pl8hfSO61Ey3hpTriVhhsCy5WnmLMI1xt7iiw81XXosabsXbhj77OMiJEmeSIg32vQKWR-SkP6oH8ZRgQaQd9ztjIn4K5p9wc9m8MTnMyf1Uwwhsxcp2dL7eMUzxcMBaNydCD8dl-PtmPXJvMoOGgFn-hC6tx24Km_e8yFMZjZ6FRKI7-VRS0DAJBX1SfmFxr1ImRsYHvqnuu1sm1kbtiPQkISBl3uwLoEfj0qDKnyZyyEnlBPa9QHG8MotLNB1-lSmdWYJOS6je4Qrse_8r3cN6UmEld6pFQe8KY8-E76os1-_y6-gL7jAnQ8irm7XZcHMQjlNMcSQFzNmqP9QXMcqUMHwEmEQRHeXrWqEYP2GEc1aOXKhwIzYCRywPt_8vOSiVdyiHcbstCNIPRD2YdaACkuare5iC-t6jyl7OfMKbTcwPbpG3DVW7tf58MlALsjCCjg223Bo112ShHv4C7UoWYZsUBtpGDzM6tPJLPs940cRsc3PBbE-0fZnGign6zxT2Icyo-hXcA8p8Bx2vpi-MOMrl2uWJuyd853pjFfGx7YSNnthhVk24r5ZhUd4forwlS4v3AQrd7Lkz54_PG9WEK_D38qNCNb7b-5sznLMI6PDiUT3ucvY2_jRzWzl86T-VrqCKJuN9kqKXABP071mKkN2TI843mdhkwtpYzDt4W-4VqbdfjvUW7uVQ6bogkqwgFWa4hFyRr1Vvp1YGI25LO7S7jVpr1_rYrN1Xllg8FlOytfqZScFIRk1Ug_aCYanegQmbx_bALRjpODzDC7HrI_HiFqPWegWVZDuAL63O2uqAKbqlsdmgQAz3F8Fwjv_WNLEQTNw&z=05AHVohkZoDlHXaWCuYQwUD_7huxFUO9jzVvoJVffYClJI1F73OMerpmlCfMQ0FcuUqnWDaMP--q3PqGod6RKml0G-8ACIlBILUHEVHjMs7SxWohtK07hB5j3vWfRCVcGFdYIxBja5DzTUs99hFTKkxQPhkIebsD4gkTNDyxW23W-ofhtelNGBpzQZnDhsfLcoe7Zikgq6TtkeN-69uNaz69llDfZRaFeE8f8RYuldRpaz6x6Ws6AvlFzI6KkJBvWXe575GSDI1jzXqMcvODTCho1sm_bqfdYQWSpslkxQD8QUJAg4vZ51WweNRzA4U6Dg53GN69uPRPIwcvnat0bkhAWfbAvnRPHQXvENZ64NsMrX9xrc7ji0jRFhIzteJkjEOdnFj58AW66xSNy4f10SUburrZyz1bVRtZB50JF3UZQBAVrODpIDaR-JJKaGNlQIUR2aa3krFfKzN3rVh7FMpMnHQsmZpI4RxG2gmpAQvbTjr4Bh6RTc52piOTYCmUozKOjAKo10l2ayggzdmvhSFpWG_0S6oJWXr_o_8OjQQxnPYRAKVAKayzUdSa3W9XIxWbD0wQPgt71LvLBWs6JNquST-tQGOIS-Cawd_OSJKjqxMm3iaH9m-AaZyk4p0t0xTPUavITWTciYQf9DCpB1di7yBkLI0yn60gEeA543Wo4LdWB8ATEgT3n9EK-SebMHNgPT0H2kjaONw4o-V8R8CofWYgtWFcMz3LnHQ5nVEwr13mGm3QPPMiLrhvHqUzOKJWELVg4GFiOAOokX)
    Mechanize.new.post('https://www.google.com/recaptcha/api2/reload?k=6Lfu78QUAAAAANSlpg06hD6SAxv02IVqDTLrhLiq', post_content.split('&').map { |a| a.split('=') }.to_h).body.scan(/rresp","(.+?)"/).first.first
  end
end
