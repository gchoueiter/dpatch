/*
 * Copyright 2008 Amazon Technologies, Inc.
 * 
 * Licensed under the Amazon Software License (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 * 
 * http://aws.amazon.com/asl
 * 
 * This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
 * OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and
 * limitations under the License.
 */ 



package com.amazonaws.mturk.cmd.test.scripts;

import com.amazonaws.mturk.cmd.test.util.ScriptRunner.ScriptResult;

import junit.textui.TestRunner;

public class TestUpdateQualificationType extends TestBase {
    
    public static void main(String[] args) {
        TestRunner.run(TestUpdateQualificationType.class);
    }

    public TestUpdateQualificationType(String arg0) {
        super(arg0);
    }

    public void testHappyCase() throws Exception {
        ScriptResult result = runScript("updateQualificationType", "--qualtypeid", "bogusID");
        assertTrue(result.getExitValue() != 0);
    }
}
