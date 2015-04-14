{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module Handler.About where

import Foundation
import Yesod.Core

getAboutR :: Handler Html
getAboutR = defaultLayout $ do
    setTitle "about passphrase.me"

    [whamlet|
        <h1>About

        <p>
            <code>curl
            -able passphrases generated using entropy from 
            <a href="https://www.random.org">random.org
            .

        <h2>Usage

        <pre>
            \% curl --silent https://passphrase-me.herokuapp.com/
            \aries selma stamp mark
            \
            \% curl --silent https://passphrase-me.herokuapp.com/?size=5
            \qualm snap come molten embark

        <h2>How it works

        <ol>
            <li>
                Request integers from 
                <a href="https://www.random.org">random.org
                , which uses things like atmospheric data to generate truly
                random numbers

            <li>
                Use those integers to look up words in 
                <a href="http://world.std.com/~reinhold/diceware.wordlist.asc">this list
                using 
                <a href="http://digitalcurrencyinstitute.org/how-to-create-super-secure-and-easily-memorable-passphrases/">this approach

            <li>
                Return those words as a simple 
                <code>text/plain
                response

        <h2>Are the passphrases strong?

        <p>
            From the web page for 
            <a href="https://www.fourmilab.ch/javascrypt/pass_phrase.html">this other generator
            :

        <blockquote>
            The relationship between the number of words in a pass phrase and
            the equivalent number of bits in an encryption key is as follows. We
            must assume [...] that the dictionary from which we choose words is
            known. This dictionary contains 27489 [..] words, so the information
            content of a word chosen randomly from the dictionary is [..] its
            order in the dictionary, 0 to 27488, or log2(27489)≈14.75 bits per
            word.

        <p>
            The word list used here has 7,776 entries. This leads to a slightly
            lower bits per word of 12.92. At the default length of 4, you're
            getting ~51 bits.

        <p>
            The inspirational 
            <a href="https://xkcd.com/936/">xkcd
            comic states it would take a computer 550 years to brute force a
            passphrase with <em>44</em> bits of entropy, so we're doing at least
            that well. If you're concerned, increase the number of words.

        <h2>Is it safe to use this site?

        <p>
            <strong>Not right now

        <p>
            See 
            <a href="https://github.com/vincenthz/hs-tls/issues/100">vincenthz/hs-tls#100
            . Because of this issue, our communication with random.org is
            currently vulnerable, as the only workaround is to not verify their
            SSL certificate.

        <p>
            Assuming this bug is eventually fixed, this site will become safe to
            use provided you access it over SSL (assuming you trust SSL in
            general).

        |]
